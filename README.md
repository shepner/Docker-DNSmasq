# [Docker-DNSmasq](https://hub.docker.com/r/shepner/docker-dnsmasq/)

Uses [Alpine Linux](https://hub.docker.com/_/alpine/), [DNSmasq](http://www.thekelleys.org.uk/dnsmasq/doc.html), and has [webproc](https://github.com/jpillora/webproc/) to previde a web interface.  New builds (should) occur whenever Alpine or this github repo is updated.
* webproc:  8080/tcp
* dns: 53/udp

DNSmasq documentation:
* http://www.thekelleys.org.uk/dnsmasq/doc.html
* http://oss.segetech.com/intra/srv/dnsmasq.conf

To run as a Docker Service from the managers rather then the nodes:
``` shell
sudo docker service create \
  --name DNSmasq \
  --publish published=53,target=53,protocol=udp,mode=ingress \
  --publish published=53,target=53,protocol=tcp,mode=ingress \
  --publish published=8080,target=8080,protocol=tcp,mode=ingress \
  --constraint node.role==manager \
  --replicas=2 \
  shepner/dnsmasq:latest
```
