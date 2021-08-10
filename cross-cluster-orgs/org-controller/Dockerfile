# syntax = docker/dockerfile:experimental

ARG baseimage=scratch

FROM golang:1.16.6 as builder

WORKDIR /
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -mod vendor -trimpath -installsuffix cgo -o org-controller .

FROM ${baseimage}
COPY --from=builder /org-controller /usr/local/bin/org-controller
USER 1001
ENTRYPOINT [ "/usr/local/bin/org-controller" ]
