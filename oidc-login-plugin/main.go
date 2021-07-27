package main

import (
	"context"
	"crypto/tls"
	"crypto/x509"
	"flag"
	"fmt"
	"io/ioutil"
	"log"
	"net"
	"net/http"
	"net/url"
	"os"
	"path/filepath"
	"time"

	"code.cloudfoundry.org/cli/plugin"
	"code.cloudfoundry.org/cli/util/configv3"
	"github.com/coreos/go-oidc/v3/oidc"
	cv "github.com/nirasan/go-oauth-pkce-code-verifier"
	"golang.org/x/oauth2"
)

const exampleAppState = "I wish to wash my irish wristwatch"

type OIDCLoginPlugin struct{}

func (c *OIDCLoginPlugin) Run(cliConnection plugin.CliConnection, args []string) {
	if args[0] == "oidc-login" {
		var flags flag.FlagSet

		clientID := flags.String("client-id", "a5fc3303a934b458e097", "OAuth2 client ID of this application.")
		clientSecret := flags.String("client-secret", "", "OAuth2 client secret of this application.")
		useImplicit := flags.Bool("implicit", false, "Use the implicit OAuth flow when authenticating (less secure)")
		redirect := flags.String("redirect-uri", "http://127.0.0.1:5555/callback", "Callback URL for OAuth2 responses.")
		issuerURL := flags.String("issuer", "https://github.com/login/oauth/authorize", "URL of the OpenID Connect issuer.")
		listen := flags.String("listen", "http://127.0.0.1:5555", "HTTP(S) address to listen at.")
		rootCAs := flags.String("issuer-root-ca", "", "Root certificate authorities for the issuer. Defaults to host certs.")

		flags.Parse(args[1:])

		redirectURI, err := url.Parse(*redirect)
		if err != nil {
			log.Fatalf("parse redirect-uri: %v", err)
		}
		listenURL, err := url.Parse(*listen)
		if err != nil {
			log.Fatalf("parse listen address: %v", err)
		}

		var client *http.Client

		if *rootCAs != "" {
			caClient, err := httpClientForRootCAs(*rootCAs)
			if err != nil {
				log.Fatal(err)
			}
			client = caClient
		}

		if client == nil {
			client = http.DefaultClient
		}

		// TODO(ericchiang): Retry with backoff
		ctx := oidc.ClientContext(context.Background(), client)
		provider, err := oidc.NewProvider(ctx, *issuerURL)
		if err != nil {
			log.Fatalf("failed to query provider %q: %v", *issuerURL, err)
		}

		verifier := provider.Verifier(&oidc.Config{ClientID: *clientID})

		codeVerifier, _ := cv.CreateCodeVerifier()
		cbHandler := &callbackHandler{
			clientID:     *clientID,
			clientSecret: *clientSecret,
			redirectURI:  *redirect,
			codeVerifier: codeVerifier.Value,
			useImplicit:  *useImplicit,

			verifier: verifier,
			provider: provider,
			client:   client,
		}

		done := make(chan struct{})
		scopes := []string{"openid", "profile", "email"}
		codeChallenge := codeVerifier.CodeChallengeS256()

		opts := []oauth2.AuthCodeOption{}
		if !*useImplicit && *clientSecret == "" {
			opts = append(opts,
				oauth2.SetAuthURLParam("code_challenge", codeChallenge),
				oauth2.SetAuthURLParam("code_challenge_method", "S256"),
			)
		}
		if *useImplicit {
			opts = append(opts,
				oauth2.SetAuthURLParam("response_type", "id_token"),
				oauth2.SetAuthURLParam("nonce", codeVerifier.Value),
			)
		}

		authCodeURL := cbHandler.oauth2Config(scopes).AuthCodeURL(exampleAppState, opts...)

		fmt.Printf("Please navigate to the following URL in your browser:\n%s\t\n", authCodeURL)

		m := http.NewServeMux()
		s := http.Server{Addr: listenURL.Host, Handler: m}
		m.HandleFunc(redirectURI.Path, func(w http.ResponseWriter, r *http.Request) {
			cbHandler.ServeHTTP(w, r)
		})
		s.ConnState = func(_ net.Conn, state http.ConnState) {

			if state == http.StateIdle {
				done <- struct{}{}
			}
		}

		go func() {
			if err := s.ListenAndServe(); err != nil && err != http.ErrServerClosed {
				log.Fatal(err)
			}
		}()

		<-done
		s.Shutdown(context.Background())
	}
}

type callbackHandler struct {
	clientID     string
	clientSecret string
	redirectURI  string
	codeVerifier string
	useImplicit  bool

	verifier *oidc.IDTokenVerifier
	provider *oidc.Provider

	client *http.Client
}

func (h *callbackHandler) oauth2Config(scopes []string) *oauth2.Config {
	return &oauth2.Config{
		ClientID:     h.clientID,
		ClientSecret: h.clientSecret,
		Endpoint:     h.provider.Endpoint(),
		Scopes:       scopes,
		RedirectURL:  h.redirectURI,
	}
}

func (h *callbackHandler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	var (
		err        error
		token      *oauth2.Token
		rawIDToken string
	)

	ctx := oidc.ClientContext(r.Context(), h.client)
	oauth2Config := h.oauth2Config(nil)
	switch r.Method {
	case http.MethodGet:
		// Authorization redirect callback from OAuth2 auth flow.
		err := r.ParseForm()
		if err != nil {
			http.Error(w, "failed to parse form", http.StatusBadRequest)
			return
		}

		if len(r.Form) == 0 {
			htmlPagePath := filepath.Join(os.Getenv("HOME"), "workspace/auth-explore/oidc-login-plugin/static/index.html")
			fmt.Println("sending html at :", htmlPagePath)
			http.ServeFile(w, r, htmlPagePath)
			return
		}
		if errMsg := r.FormValue("error"); errMsg != "" {
			http.Error(w, errMsg+": "+r.FormValue("error_description"), http.StatusBadRequest)
			return
		}
		rawIDToken = r.FormValue("id_token")
		if rawIDToken != "" {
			// TODO: check nonce value
			break
		}
		code := r.FormValue("code")
		if code == "" {
			http.Error(w, fmt.Sprintf("no code in request: %q", r.Form), http.StatusBadRequest)
			return
		}
		if state := r.FormValue("state"); state != exampleAppState {
			http.Error(w, fmt.Sprintf("expected state %q got %q", exampleAppState, state), http.StatusBadRequest)
			return
		}

		opts := []oauth2.AuthCodeOption{}
		if h.clientSecret == "" && !h.useImplicit {
			opts = append(opts, oauth2.SetAuthURLParam("code_verifier", h.codeVerifier))
		}

		token, err = oauth2Config.Exchange(ctx, code, opts...)
		if err != nil {
			http.Error(w, fmt.Sprintf("failed to exchange code for token %v", err), http.StatusBadRequest)
			return
		}

		var ok bool
		rawIDToken, ok = token.Extra("id_token").(string)
		if !ok {
			http.Error(w, "no id_token in token response", http.StatusInternalServerError)
			return
		}
	default:
		http.Error(w, fmt.Sprintf("method not implemented: %s", r.Method), http.StatusBadRequest)
		return
	}

	if err != nil {
		http.Error(w, fmt.Sprintf("failed to get token: %v", err), http.StatusInternalServerError)
		return
	}

	config, err := configv3.LoadConfig()
	if err != nil {
		http.Error(w, fmt.Sprintf("failed to load config: %v", err), http.StatusInternalServerError)
		return
	}
	config.ConfigFile.AccessToken = "bearer " + rawIDToken
	err = config.WriteConfig()
	if err != nil {
		http.Error(w, fmt.Sprintf("failed to write config: %v", err), http.StatusInternalServerError)
		return
	}

	fmt.Fprintf(w, "Authentication successful! You can close this window!")
}

func httpClientForRootCAs(rootCAs string) (*http.Client, error) {
	tlsConfig := tls.Config{RootCAs: x509.NewCertPool()}
	rootCABytes, err := ioutil.ReadFile(rootCAs)
	if err != nil {
		return nil, fmt.Errorf("failed to read root-ca: %v", err)
	}
	if !tlsConfig.RootCAs.AppendCertsFromPEM(rootCABytes) {
		return nil, fmt.Errorf("no certs found in root CA file %q", rootCAs)
	}
	return &http.Client{
		Transport: &http.Transport{
			TLSClientConfig: &tlsConfig,
			Proxy:           http.ProxyFromEnvironment,
			Dial: (&net.Dialer{
				Timeout:   30 * time.Second,
				KeepAlive: 30 * time.Second,
			}).Dial,
			TLSHandshakeTimeout:   10 * time.Second,
			ExpectContinueTimeout: 1 * time.Second,
		},
	}, nil
}

func (c *OIDCLoginPlugin) GetMetadata() plugin.PluginMetadata {
	return plugin.PluginMetadata{
		Name: "OIDCLoginPlugin",
		LibraryVersion: plugin.VersionType{
			Major: 2,
		},
		Version: plugin.VersionType{
			Major: 0,
			Minor: 0,
			Build: 1,
		},
		MinCliVersion: plugin.VersionType{
			Major: 6,
			Minor: 7,
			Build: 0,
		},
		Commands: []plugin.Command{
			{
				Name:     "oidc-login",
				HelpText: "Login with an OIDC provider",
				UsageDetails: plugin.Usage{
					Usage: "oidc-login\n   cf oidc-login",
				},
			},
		},
	}
}

func main() {
	plugin.Start(new(OIDCLoginPlugin))
}
