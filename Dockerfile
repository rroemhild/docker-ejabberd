FROM debian:7
MAINTAINER Rafael Römhild <rafael@roemhild.de>

ENV EJABBERD_VERSION 15.03
ENV EJABBERD_USER ejabberd
ENV EJABBERD_ROOT /opt/ejabberd
ENV EJABBERD_WEB_ADMIN_SSL true
ENV EJABBERD_S2S_SSL true
ENV HOME $EJABBERD_ROOT
ENV PATH $EJABBERD_ROOT/bin:/usr/sbin:/usr/bin:/sbin:/bin
ENV DEBIAN_FRONTEND noninteractive
ENV XMPP_DOMAIN localhost

# Add ejabberd user and group
RUN groupadd -r $EJABBERD_USER \
    && useradd -r -m \
       -g $EJABBERD_USER \
       -d $EJABBERD_ROOT \
       -s /usr/sbin/nologin \
       $EJABBERD_USER

# Install requirements
RUN apt-get update \
    && apt-get -y --no-install-recommends install \
        curl \
        python2.7 \
        python-jinja2 \
        ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install as user
USER $EJABBERD_USER

# Install ejabberd
## --keyserver is required for debian wheezy (not for jessie).
RUN gpg --keyserver hkp://hkps.pool.sks-keyservers.net --recv-keys 31468D18DF9841242B90D7328ECA469419C09311 \
    && curl --silent --output /tmp/ejabberd-installer.run.asc -L "https://www.process-one.net/downloads/downloads-action.php?file=/ejabberd/$EJABBERD_VERSION/ejabberd-$EJABBERD_VERSION-linux-x86_64-installer.run.asc" \
    && curl --silent --output /tmp/ejabberd-installer.run -L "https://www.process-one.net/downloads/downloads-action.php?file=/ejabberd/$EJABBERD_VERSION/ejabberd-$EJABBERD_VERSION-linux-x86_64-installer.run" \
    && gpg --verify /tmp/ejabberd-installer.run.asc \
    && chmod +x /tmp/ejabberd-installer.run \
    && /tmp/ejabberd-installer.run \
            --mode unattended \
            --prefix $EJABBERD_ROOT \
            --adminpw ejabberd \
    && rm -rf /tmp/* \
    && mkdir $EJABBERD_ROOT/ssl \
    && rm -rf $EJABBERD_ROOT/database/ejabberd@localhost

# Make config
COPY ejabberd.yml.tpl $EJABBERD_ROOT/conf/ejabberd.yml.tpl
COPY ejabberdctl.cfg.tpl $EJABBERD_ROOT/conf/ejabberdctl.cfg.tpl
RUN sed -i "s/ejabberd.cfg/ejabberd.yml/" $EJABBERD_ROOT/bin/ejabberdctl \
    && sed -i "s/root/$EJABBERD_USER/g" $EJABBERD_ROOT/bin/ejabberdctl

# Wrapper for setting config on disk from environment
# allows setting things like XMPP domain at runtime
COPY ./run $EJABBERD_ROOT/bin/run

# Add run scripts
ADD ./scripts $EJABBERD_ROOT/bin/scripts

# Set workdir to ejabberd root
WORKDIR $EJABBERD_ROOT

VOLUME ["$EJABBERD_ROOT/database", "$EJABBERD_ROOT/ssl"]
EXPOSE 4369 4560 5222 5269 5280

CMD ["start"]
ENTRYPOINT ["run"]
