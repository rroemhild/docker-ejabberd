FROM ubuntu:14.04
MAINTAINER Rafael Römhild <rafael@roemhild.de>

ENV EJABBERD_VERSION 14.12
ENV EJABBERD_USER ejabberd
ENV EJABBERD_ROOT /opt/ejabberd
ENV HOME $EJABBERD_ROOT
ENV PATH $EJABBERD_ROOT/bin:/usr/sbin:/usr/bin:/sbin:/bin
ENV DEBIAN_FRONTEND noninteractive

# Add ejabberd user and group
RUN groupadd -r $EJABBERD_USER \
    && useradd -r -m \
       -g $EJABBERD_USER \
       -d $EJABBERD_ROOT \
       -s /usr/sbin/nologin \
       $EJABBERD_USER

# Install erlang and requirements
RUN apt-get update && apt-get -y install \
        wget \
        libexpat1 \
        erlang-nox \
        libyaml-0-2 \
        python-jinja2 \
    && rm -rf /var/lib/apt/lists/*

# Install as user
USER $EJABBERD_USER

# Install ejabberd
RUN wget -q -O /tmp/ejabberd-installer.run "http://www.process-one.net/downloads/downloads-action.php?file=/ejabberd/$EJABBERD_VERSION/ejabberd-$EJABBERD_VERSION-linux-x86_64-installer.run" \
    && chmod +x /tmp/ejabberd-installer.run \
    && /tmp/ejabberd-installer.run \
            --mode unattended \
            --prefix $EJABBERD_ROOT \
            --adminpw ejabberd \
    && rm -rf /tmp/* \
    && mkdir $EJABBERD_ROOT/ssl

# config
COPY ejabberd.yml.tpl $EJABBERD_ROOT/conf/ejabberd.yml.tpl
COPY ejabberdctl.cfg.tpl $EJABBERD_ROOT/conf/ejabberdctl.cfg.tpl
RUN sed -i "s/ejabberd.cfg/ejabberd.yml/" $EJABBERD_ROOT/bin/ejabberdctl \
    && sed -i "s/root/$EJABBERD_USER/g" $EJABBERD_ROOT/bin/ejabberdctl

# wrapper for setting config on disk from environment
# allows setting things like XMPP domain at runtime
COPY ./run $EJABBERD_ROOT/bin/run

VOLUME ["$EJABBERD_ROOT/database", "$EJABBERD_ROOT/ssl"]
EXPOSE 5222 5269 5280 4560

CMD ["start"]
ENTRYPOINT ["run"]
