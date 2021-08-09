# syntax = docker/dockerfile:experimental

ARG baseimage=scratch

FROM golang:1.16.6 as builder

WORKDIR /
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -trimpath -installsuffix cgo -o multicluster-controller .

FROM ${baseimage}
COPY --from=builder /multicluster-controller /usr/local/bin/multicluster-controller
USER 1001
ENTRYPOINT [ "/usr/local/bin/multicluster-controller" ]
