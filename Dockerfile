FROM alpine as builder

RUN apk --update add curl tar
RUN curl -L https://github.com/neezer/deinde/releases/download/1.0.0-alpha.1/deinde_alpine_amd64.tar.gz | tar xz > /usr/local/bin/deinde
RUN chmod +x /usr/local/bin/deinde

FROM alpine

RUN apk --update add git
RUN mkdir -p /workdir
WORKDIR /workdir

COPY --from=builder /usr/local/bin/deinde /usr/local/bin/deinde
COPY release-to-github.sh /usr/local/bin/release-to-github.sh

ENTRYPOINT ["/usr/local/bin/release-to-github.sh"]
