FROM ubuntu:16.04

MAINTAINER Dirceu Silva <docker@dirceusilva.com>

RUN apt-get update && apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    lxc \
    git-core \
    iptables


###########
# PYTHON3 #
###########
RUN apt-get update \
  && apt-get install -y python3-pip python3-dev \
  && cd /usr/local/bin \
  && ln -s /usr/bin/python3 python \
  && pip3 install --upgrade pip




##########
# DOCKER #
##########
RUN curl -sSL https://get.docker.com/ | sh

# Wrapper docker ninja...
COPY ./wrapdocker /usr/local/bin/wrapdocker
RUN chmod +x /usr/local/bin/wrapdocker

VOLUME /var/lib/docker
CMD ["wrapdocker"]




##################
# DOCKER-COMPOSE #
##################
RUN pip3 install docker-compose
RUN docker-compose version



###########
# KUBECTL #
###########
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl \
    && chmod +x ./kubectl \
    && mv ./kubectl /usr/local/bin/kubectl








COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT ["docker-entrypoint.sh"]
