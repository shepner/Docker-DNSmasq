# [Docker-DNSmasq](https://hub.docker.com/r/shepner/docker-dnsmasq/)

Uses [Alpine Linux](https://hub.docker.com/_/alpine/), [DNSmasq](http://www.thekelleys.org.uk/dnsmasq/doc.html), and has [webproc](https://github.com/jpillora/webproc/) to previde a web interface.  New builds (should) occur whenever Alpine or this github repo is updated

## Instructions

Before you do anything, you must disable any DNS server running on the local host or this will fail.  Ubuntu Server 18.04, for some dumb reason, has one (I think DNSmasq) running by default which is listening on all interfaces.


To run as a combined DNS/DHCP server in a docker swarm:
``` shell
mkdir -p /mnt/nas/docker/dnsmasq/config

wget -O /mnt/nas/docker/dnsmasq/program.toml https://raw.githubusercontent.com/shepner/Docker-DNSmasq/master/program.toml
wget -O /mnt/nas/docker/dnsmasq/resolv.conf https://raw.githubusercontent.com/shepner/Docker-DNSmasq/master/resolv.conf
wget -O /mnt/nas/docker/dnsmasq/config/dnsmasq.conf https://raw.githubusercontent.com/shepner/Docker-DNSmasq/master/dnsmasq.conf

sudo docker service create \
  --name DNSmasq \
  --mount type=bind,src=/mnt/nas/docker/dnsmasq,dst=/mnt \
  --network host \
  --constraint node.role!=manager \
  --replicas=1 \
  shepner/dnsmasq:latest
```
NOTE: You will only want 1 instance with this to prevent dualing DHCP servers

---
## work in progress
---

need to find a way to split the DNS and DHCP while utilizing a single config directory.  Biggest problem seems to be with program.toml as it cant be renamed

To run as just a DNS server in a docker swarm
``` shell
mkdir -p /mnt/nas/docker/dnsmasq/config

wget -O /mnt/nas/docker/dnsmasq/program.toml https://raw.githubusercontent.com/shepner/Docker-DNSmasq/master/program.toml
wget -O /mnt/nas/docker/dnsmasq/resolv.conf https://raw.githubusercontent.com/shepner/Docker-DNSmasq/master/resolv.conf
wget -O /mnt/nas/docker/dnsmasq/config/dnsmasq.conf https://raw.githubusercontent.com/shepner/Docker-DNSmasq/master/dnsmasq.conf

sudo docker service create \
  --name DNSmasq-dns \
  --publish published=53,target=53,protocol=udp,mode=ingress \
  --publish published=53,target=53,protocol=tcp,mode=ingress \
  --publish published=8080,target=8080,protocol=tcp,mode=ingress \
  --mount type=bind,src=/mnt/nas/docker/dnsmasq,dst=/mnt \
  --constraint node.role!=manager \
  --replicas=2 \
  shepner/dnsmasq:latest
```


To run just as a DHCP server in a docker swarm
``` shell
mkdir -p /mnt/nas/docker/dnsmasq/config

wget -O /mnt/nas/docker/dnsmasq/program.toml https://raw.githubusercontent.com/shepner/Docker-DNSmasq/master/program.toml
wget -O /mnt/nas/docker/dnsmasq/resolv.conf https://raw.githubusercontent.com/shepner/Docker-DNSmasq/master/resolv.conf
wget -O /mnt/nas/docker/dnsmasq/config/dnsmasq.conf https://raw.githubusercontent.com/shepner/Docker-DNSmasq/master/dnsmasq.conf

sudo docker service create \
  --name DNSmasq-dhcp \
  --mount type=bind,src=/mnt/nas/docker/dnsmasq,dst=/mnt \
  --network host \
  --constraint node.role!=manager \
  --replicas=1 \
  shepner/dnsmasq:latest
```
* this talks about using pipework to support DHCP
  * https://hub.docker.com/r/kmanna/dnsmasq/
  * https://github.com/jpetazzo/pipework
* https://stackoverflow.com/questions/38816077/run-dnsmasq-as-dhcp-server-from-inside-a-docker-container
* https://serverfault.com/questions/825497/running-dnsmasq-in-docker-container-on-debian-check-dhcp-ignores-dnsmasq


## DNSmasq documentation

* http://www.thekelleys.org.uk/dnsmasq/doc.html
* http://oss.segetech.com/intra/srv/dnsmasq.conf

