FROM ubuntu:14.04
MAINTAINER Rafael Römhild <rafael@roemhild.de>

ENV HOME /opt/ejabberd
ENV EJABBERD_VERSION 14.07
ENV DEBIAN_FRONTEND noninteractive

# Install erlang and requirements
RUN apt-get update && apt-get -y install \
        wget \
        libexpat1 \
        erlang-nox \
        libyaml-0-2 \
        python-jinja2 \
    && rm -rf /var/lib/apt/lists/*

# ejabberd
RUN wget -q -O /tmp/ejabberd-installer.run "http://www.process-one.net/downloads/downloads-action.php?file=/ejabberd/$EJABBERD_VERSION/ejabberd-$EJABBERD_VERSION-linux-x86_64-installer.run" \
    && chmod +x /tmp/ejabberd-installer.run \
    && /tmp/ejabberd-installer.run \
            --mode unattended \
            --prefix /opt/ejabberd \
            --adminpw ejabberd \
    && rm -rf /tmp/*

# config
COPY ./ejabberd.yml.tpl /opt/ejabberd/conf/ejabberd.yml.tpl
COPY ./ejabberdctl.cfg /opt/ejabberd/conf/ejabberdctl.cfg
RUN sed -i "s/ejabberd.cfg/ejabberd.yml/" /opt/ejabberd/bin/ejabberdctl \
    && sed -i "s/root/ejabberd/g" /opt/ejabberd/bin/ejabberdctl

# wrapper for setting config on disk from environment
# allows setting things like XMPP domain at runtime
COPY ./run /opt/ejabberd/bin/run

# Add ejabberd user and group
RUN groupadd -r ejabberd \
    && useradd -r -g ejabberd -d /opt/ejabberd -s /usr/sbin/nologin ejabberd \
    && mkdir /opt/ejabberd/ssl \
    && chown -R ejabberd:ejabberd /opt/ejabberd

USER ejabberd
VOLUME ["/opt/ejabberd/database", "/opt/ejabberd/ssl"]
EXPOSE 5222 5269 5280

CMD ["live"]
ENTRYPOINT ["/opt/ejabberd/bin/run"]
