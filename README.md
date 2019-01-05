# [Docker-DNSmasq](https://hub.docker.com/r/shepner/docker-dnsmasq/)

Uses [Alpine Linux](https://hub.docker.com/_/alpine/), [DNSmasq](http://www.thekelleys.org.uk/dnsmasq/doc.html), and has [webproc](https://github.com/jpillora/webproc/) to previde a web interface.  New builds (should) occur whenever Alpine or this github repo is updated.
* webproc:  8080/tcp
* dns: 53/udp

## Instructions

To run as a Docker Service from the managers rather then the nodes:
``` shell
mkdir -p /mnt/nas/docker/dnsmasq/config

wget -O /mnt/nas/docker/dnsmasq/program.toml https://raw.githubusercontent.com/shepner/Docker-DNSmasq/master/program.toml
wget -O /mnt/nas/docker/dnsmasq/resolv.conf https://raw.githubusercontent.com/shepner/Docker-DNSmasq/master/resolv.conf
wget -O /mnt/nas/docker/dnsmasq/config/dnsmasq.conf https://raw.githubusercontent.com/shepner/Docker-DNSmasq/master/dnsmasq.conf

sudo docker service create \
  --name DNSmasq \
  --publish published=53,target=53,protocol=udp,mode=ingress \
  --publish published=53,target=53,protocol=tcp,mode=ingress \
  --publish published=8080,target=8080,protocol=tcp,mode=ingress \
  --mount type=bind,src=/mnt/nas/docker/dnsmasq,dst=/mnt \
  --constraint node.role==manager \
  --replicas=2 \
  shepner/dnsmasq:latest
```

## DNSmasq documentation

* http://www.thekelleys.org.uk/dnsmasq/doc.html
* http://oss.segetech.com/intra/srv/dnsmasq.conf

## Notes

Running DNSmasq as a DHCP server from a container is going to take some work
* this talks about using pipework to support DHCP
  * https://hub.docker.com/r/kmanna/dnsmasq/
  * https://github.com/jpetazzo/pipework
* https://stackoverflow.com/questions/38816077/run-dnsmasq-as-dhcp-server-from-inside-a-docker-container
* https://serverfault.com/questions/825497/running-dnsmasq-in-docker-container-on-debian-check-dhcp-ignores-dnsmasq

This seems likely to be the solution (if I can disable the local DHCP server on the host):
``` shell
sudo docker service create \
  --name DNSmasq \
  --mount type=bind,src=/mnt/nas/docker/dnsmasq,dst=/mnt \
  --network host \
  --constraint node.role!=manager \
  --replicas=1 \
  shepner/dnsmasq:latest
```

``` shell
docker run --name dnsmasq -t -v /mnt/nas/docker/dnsmasq:/mnt --net host shepner/dnsmasq:latest
```
