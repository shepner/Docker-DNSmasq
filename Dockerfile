FROM alpine:latest

LABEL \
  org.asyla.release-date="2019-01-2" \
  org.asyla.maintainer="shepner@asyla.org" \
  org.asyla.description="DNSmasq:  DNS Server"

# Webproc release settings
ENV WEBPROC_VERSION=0.2.2
ENV WEBPROC_URL=https://github.com/jpillora/webproc/releases/download/$WEBPROC_VERSION/webproc_linux_amd64.gz
ENV WEBPROC_CONF=/mnt/webproc/program.toml

# Fetch dnsmasq and webproc binary
RUN apk update \
      && apk add --no-cache dnsmasq \
      && apk add --no-cache --virtual .build-deps curl \
      && curl -sL $WEBPROC_URL | gzip -d - > /usr/local/bin/webproc \
      && chmod +x /usr/local/bin/webproc \
      && apk del .build-deps

# Configure dnsmasq
VOLUME ["/mnt"]  # location of external files

# Document what ports are available
EXPOSE 53/udp
EXPOSE 53/tcp
EXPOSE 8080/tcp

# Run
ENTRYPOINT ["webproc","$WEBPROC_CONF"]

