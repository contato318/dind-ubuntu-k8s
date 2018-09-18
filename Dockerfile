FROM ubuntu:16.04

MAINTAINER Dirceu Silva <docker@dirceusilva.com>

RUN apt-get update -qq && apt-get install -qqy \
    apt-transport-https \
    ca-certificates \
    curl \
    lxc \
    iptables

RUN curl -sSL https://get.docker.com/ | sh

# Wrapper .
ADD ./wrapdocker /usr/local/bin/wrapdocker
RUN chmod +x /usr/local/bin/wrapdocker

k8sVOLUME /var/lib/docker
CMD ["wrapdocker"]
