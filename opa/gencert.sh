#!/bin/bash

set -euxo pipefail

mkdir -p ssl

pushd ssl
{
  openssl genrsa -out ca.key 2048
  openssl req -x509 -new -nodes -key ca.key -days 100000 -out ca.crt -subj "/CN=admission_ca"
  cat >server.conf <<EOF
[req]
req_extensions = v3_req
distinguished_name = req_distinguished_name
prompt = no
[req_distinguished_name]
CN = localhost
[ v3_req ]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
extendedKeyUsage = clientAuth, serverAuth
subjectAltName = @alt_names
[alt_names]
DNS.1 = localhost
DNS.2 = opa.opa.svc
EOF

  openssl genrsa -out server.key 2048
  openssl req -new -key server.key -out server.csr -config server.conf
  openssl x509 -req -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out server.crt -days 100000 -extensions v3_req -extfile server.conf
}
popd
