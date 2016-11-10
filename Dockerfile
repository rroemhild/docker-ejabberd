FROM debian:jessie
MAINTAINER Rafael Römhild <rafael@roemhild.de>

ENV PATH /opt/ejabberd/bin:/usr/sbin:/usr/bin:/sbin:/bin
ENV EJABBERD_HOME /opt/ejabberd
ENV XMPP_DOMAIN localhost

# Set default locale for the environment
ENV LC_ALL=C.UTF-8 LANG=en_US.UTF-8 LANGUAGE=en_US.UTF-8

# bootstrap
COPY docker/bootstrap.sh /tmp/bootstrap.sh
RUN /tmp/bootstrap.sh

# Continue as user
USER ejabberd

# copy docker container files
COPY docker /opt/ejabberd/docker

# Set workdir to ejabberd root
WORKDIR /opt/ejabberd

VOLUME ["/opt/ejabberd/conf", "/opt/ejabberd/database", "/opt/ejabberd/ssl", "/opt/ejabberd/backup", "/opt/ejabberd/upload", "/opt/ejabberd/modules"]

EXPOSE 4560 5222 5269 5280 5443

CMD ["/opt/ejabberd/docker/start.sh"]
