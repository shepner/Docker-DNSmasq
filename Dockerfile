FROM alpine:latest

LABEL \
  org.asyla.release-date="2019-01-2" \
  org.asyla.maintainer="shepner@asyla.org" \
  org.asyla.description="DNSmasq:  DNS Server"

# Webproc release settings
ENV WEBPROC_VERSION=0.2.2
ENV WEBPROC_URL=https://github.com/jpillora/webproc/releases/download/$WEBPROC_VERSION/webproc_linux_amd64.gz

# Fetch dnsmasq and webproc binary
RUN apk update \
      && apk add --no-cache dnsmasq \
      && apk add --no-cache --virtual .build-deps curl \
      && curl -sL $WEBPROC_URL | gzip -d - > /usr/local/bin/webproc \
      && chmod +x /usr/local/bin/webproc \
      && apk del .build-deps

# Configure webproc
RUN mkdir -p /etc
COPY program.toml /etc/program.toml

# Configure dnsmasq
#RUN mkdir -p /etc/default/
#RUN echo -e "ENABLED=1\nIGNORE_RESOLVCONF=yes" > /etc/default/dnsmasq
#COPY resolv.conf /etc/resolv.conf
#COPY dnsmasq.conf /etc/dnsmasq.conf
VOLUME ["/mnt"]  # location of external files

# Run
#CMD ["webproc","--config","/etc/dnsmasq.conf","--","dnsmasq","--no-daemon"]
CMD ["webproc","/mnt/program.toml"]

