FROM debian:jessie
MAINTAINER Rafael Römhild <rafael@roemhild.de>

ENV PATH /opt/ejabberd/bin:/usr/sbin:/usr/bin:/sbin:/bin
ENV EJABBERD_HOME /opt/ejabberd
ENV XMPP_DOMAIN localhost

# Set default locale for the environment
ENV LC_ALL C.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8

# bootstrap
COPY docker/bootstrap.sh /bootstrap.sh
RUN /bootstrap.sh

# Add config templates
COPY conf /tmp/conf

# change owner for ejabberd home
RUN chown -R ejabberd /opt/ejabberd

# Continue as user
USER ejabberd

# copy docker container files
COPY docker /opt/ejabberd/docker

# Set workdir to ejabberd root
WORKDIR /opt/ejabberd

VOLUME ["/opt/ejabberd/database", "/opt/ejabberd/ssl", "/opt/ejabberd/backup", "/opt/ejabberd/upload"]

EXPOSE 4560 5222 5269 5280 5443

CMD ["/opt/ejabberd/docker/run.sh"]
