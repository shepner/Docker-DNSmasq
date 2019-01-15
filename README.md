# [Docker-DNSmasq](https://hub.docker.com/r/shepner/docker-dnsmasq/)

Uses [Alpine Linux](https://hub.docker.com/_/alpine/), [DNSmasq](http://www.thekelleys.org.uk/dnsmasq/doc.html), and has [webproc](https://github.com/jpillora/webproc/) to previde a web interface.  New builds (should) occur whenever Alpine or this github repo is updated

## Instructions

This setup is a bit more difficult then others mainly to provide more flexability.  It can be make considerably simpler if you dont mind reducing your options.

NOTE: Before you do anything, you must disable any DNS server running on the local host or this will fail.  Ubuntu Server 18.04, for some dumb reason, has one (I think DNSmasq) running by default which is listening on all interfaces.

NOTE:  In all cases, you will have to do a great deal of configuration here to have anything more then a basic DNS resolver

### run as just a DNS server in a docker swarm

Point your DNS clients to an assortment of the physical host addresses.  All in the swarm will work equally well.

``` shell
mkdir -p /mnt/nas/docker/dnsmasq/config
mkdir -p /mnt/nas/docker/dnsmasq/webproc

wget -O /mnt/nas/docker/dnsmasq/program.toml https://raw.githubusercontent.com/shepner/Docker-DNSmasq/master/program.toml
wget -O /mnt/nas/docker/dnsmasq/config/dnsmasq.conf https://raw.githubusercontent.com/shepner/Docker-DNSmasq/master/dnsmasq.conf
wget -O /mnt/nas/docker/dnsmasq/resolv.conf https://raw.githubusercontent.com/shepner/Docker-DNSmasq/master/resolv.conf

sudo docker service create \
  --name DNSmasq-dns \
  --publish published=53,target=53,protocol=udp,mode=ingress \
  --publish published=53,target=53,protocol=tcp,mode=ingress \
  --publish published=8053,target=8053,protocol=tcp,mode=ingress \
  --mount type=bind,src=/mnt/nas/docker/dnsmasq,dst=/mnt \
  --constraint node.role!=manager \
  --replicas=2 \
  shepner/dnsmasq:latest
```

### run just as a DHCP server in a docker swarm

Use port 8067 to manage this

Set your DHCP relay service to point at all physical nodes that this could possibly run on.

This needs '--privileged' to resolve the "⁣⁣dnsmasq-dhcp: ARP-cache injection failed: Operation not permitted" error but that isnt available with docker swarm

``` shell
mkdir -p /mnt/nas/docker/dnsmasq/config
mkdir -p /mnt/nas/docker/dnsmasq/webproc_dhcp

wget -O /mnt/nas/docker/dnsmasq/webproc_dhcp/program.toml https://raw.githubusercontent.com/shepner/Docker-DNSmasq/master/program.toml
wget -O /mnt/nas/docker/dnsmasq/config/dnsmasq_dhcp.conf https://raw.githubusercontent.com/shepner/Docker-DNSmasq/master/dnsmasq.conf
wget -O /mnt/nas/docker/dnsmasq/config/dnsmasq.conf https://raw.githubusercontent.com/shepner/Docker-DNSmasq/master/dnsmasq.conf
wget -O /mnt/nas/docker/dnsmasq/resolv.conf https://raw.githubusercontent.com/shepner/Docker-DNSmasq/master/resolv.conf

sudo docker service create \
  --name DNSmasq-dhcp \
  --env WEBPROC_CONF=/mnt/webproc_dhcp/program.toml \
  --mount type=bind,src=/mnt/nas/docker/dnsmasq,dst=/mnt \
  --network host \
  --constraint node.role!=manager \
  --replicas=1 \
  shepner/dnsmasq:latest
```
NOTE: You will only want 1 instance with this to prevent dualing DHCP servers

Notes related to this:
* this talks about using pipework to support DHCP
  * https://hub.docker.com/r/kmanna/dnsmasq/
  * https://github.com/jpetazzo/pipework
* https://stackoverflow.com/questions/38816077/run-dnsmasq-as-dhcp-server-from-inside-a-docker-container
* https://serverfault.com/questions/825497/running-dnsmasq-in-docker-container-on-debian-check-dhcp-ignores-dnsmasq

### run as a combined DNS/DHCP server in a docker swarm

You prolly dont want to do this but its here for documentation sake

``` shell
mkdir -p /mnt/nas/docker/dnsmasq/config

wget -O /mnt/nas/docker/dnsmasq/program.toml https://raw.githubusercontent.com/shepner/Docker-DNSmasq/master/program.toml
wget -O /mnt/nas/docker/dnsmasq/config/dnsmasq.conf https://raw.githubusercontent.com/shepner/Docker-DNSmasq/master/dnsmasq.conf
wget -O /mnt/nas/docker/dnsmasq/resolv.conf https://raw.githubusercontent.com/shepner/Docker-DNSmasq/master/resolv.conf

sudo docker service create \
  --name DNSmasq \
  --mount type=bind,src=/mnt/nas/docker/dnsmasq,dst=/mnt \
  --env WEBPROC_CONF=/mnt/program.toml \
  --network host \
  --constraint node.role!=manager \
  --replicas=1 \
  shepner/dnsmasq:latest
```
NOTE: You will only want 1 instance with this to prevent dualing DHCP servers

## DNSmasq documentation

* http://www.thekelleys.org.uk/dnsmasq/doc.html
* http://oss.segetech.com/intra/srv/dnsmasq.conf

