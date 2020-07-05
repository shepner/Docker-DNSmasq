FROM alpine:latest

# Fetch dnsmasq and webproc binary
RUN apk update \
      && apk add --no-cache dnsmasq \
      && apk add --no-cache bash \
      && apk add --no-cache --virtual .build-deps curl \
      && cd /usr/local/bin; curl https://i.jpillora.com/webproc | bash \
      && apk del .build-deps

# Configure dnsmasq
VOLUME ["/mnt"]  # location of external files

# Document what ports are available
EXPOSE 53/udp
EXPOSE 53/tcp
EXPOSE 8080/tcp

# Run
#ENTRYPOINT ["webproc","/mnt/program.toml"]
ENV WEBPROC_CONF=/mnt/webproc/program.toml
#ENTRYPOINT webproc $WEBPROC_CONF
CMD ["/bin/sh"]
