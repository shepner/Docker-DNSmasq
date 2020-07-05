FROM alpine:latest

# Fetch dnsmasq and webproc binary
RUN apk update \
    && apk add --no-cache dnsmasq \
    && apk add --no-cache --virtual .build-deps curl bash \
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
# For some reason webproc wont start with the program.toml file anymore so must do this the hard way
CMD ["webproc", "--port", "8053", "-c", "/mnt/hosts", "-c", "/mnt/resolv.conf", "-c", "/mnt/dnsmasq.leases", "-c", "/mnt/config/dnsmasq_combined.conf",  "--", "dnsmasq", "--no-daemon", "--conf-file=/mnt/config/dnsmasq_combined.conf"]
