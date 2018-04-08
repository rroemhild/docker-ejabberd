FROM alpine:3.7
MAINTAINER Marek Walczak <marek@walczak.io>

ENV EJABBERD_BRANCH=18.03 \
    EJABBERD_USER=ejabberd \
    EJABBERD_HTTPS=true \
    EJABBERD_STARTTLS=true \
    EJABBERD_S2S_SSL=true \
    EJABBERD_HOME=/opt/ejabberd \
    EJABBERD_DEBUG_MODE=false \
    HOME=$EJABBERD_HOME \
    PATH=$EJABBERD_HOME/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/sbin \
    XMPP_DOMAIN=localhost \
    GOSU_VERSION=1.10

# Install packages and perform cleanup
RUN apk -U upgrade --update musl && \
    apk add -t buildDep \
        automake \
        autoconf \
        build-base \
        # dirmngr \
        dpkg \
        erlang-dev \
        git \
        gnupg \
        expat-dev \
        gd-dev \
        jpeg-dev \
        libpng-dev \
        libwebp-dev \
        openssl-dev \
        shadow \
        sqlite-dev \
        yaml-dev \
        wget \
        zlib-dev \
  && apk add \
        bash \
        bind-tools \
        ca-certificates \
        elixir \
        erlang-erts erlang-mnesia erlang-snmp erlang-ssl erlang-ssh \
        erlang-tools erlang-xmerl erlang-diameter erlang-eldap \
        erlang-syntax-tools erlang-eunit erlang-ic erlang-odbc erlang-os-mon \
        erlang-parsetools erlang-crypto erlang-hipe \
        erlang-runtime-tools erlang-reltool \
        imagemagick \
        inotify-tools \
        libgd \
        libwebp \
        openssl \
        python2 \
        py2-jinja2 \
        py-mysqldb \
        yaml \
        # erlang-corba locales
        # erlang-src
    && mix local.hex --force  \
    && mix local.rebar --force \
    && mkdir -p $EJABBERD_HOME \
    && groupadd -r $EJABBERD_USER \
    && useradd -r -m \
       -u 999 \
       -g $EJABBERD_USER \
       -d $EJABBERD_HOME \
       $EJABBERD_USER \
    && cd /tmp \
    && git clone https://github.com/processone/ejabberd.git \
        --branch $EJABBERD_BRANCH --single-branch --depth=1 \
    && cd ejabberd \
    && chmod +x ./autogen.sh \
    && ./autogen.sh \
    && ./configure --enable-user=$EJABBERD_USER \
        --enable-all \
        --disable-tools \
        --disable-pam \
    && make debug=$EJABBERD_DEBUG_MODE \
    && make install \
    && mkdir $EJABBERD_HOME/ssl \
    && mkdir $EJABBERD_HOME/conf \
    && mkdir $EJABBERD_HOME/backup \
    && mkdir $EJABBERD_HOME/upload \
    && mkdir $EJABBERD_HOME/database \
    && mkdir $EJABBERD_HOME/module_source \
    && cd $EJABBERD_HOME \
    && rm -rf /tmp/ejabberd \
    && rm -rf /etc/ejabberd \
    && ln -sf $EJABBERD_HOME/conf /etc/ejabberd \
    && rm -rf /usr/local/etc/ejabberd \
    && ln -sf $EJABBERD_HOME/conf /usr/local/etc/ejabberd \
    && chown -R $EJABBERD_USER: $EJABBERD_HOME \
    && wget -P /usr/local/share/ca-certificates/cacert.org http://www.cacert.org/certs/root.crt http://www.cacert.org/certs/class3.crt \
    && update-ca-certificates \
    && set -ex \
    && dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')" \
    && wget -O /usr/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch" \
    && wget -O /usr/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch.asc" \
# verify the signature
    && export GNUPGHOME="$(mktemp -d)" \
    && for server in $(shuf -e ha.pool.sks-keyservers.net \
                             hkp://p80.pool.sks-keyservers.net:80 \
                             keyserver.ubuntu.com \
                             hkp://keyserver.ubuntu.com:80 \
                             pgp.mit.edu) ; do \
         gpg --keyserver "$server" --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 && break || : ; \
     done \
    && gpg --batch --verify /usr/bin/gosu.asc /usr/bin/gosu \
    && chmod +sx /usr/bin/gosu \
    && gosu nobody true \
# cleanup
    && rm -r /usr/bin/gosu.asc \
    && apk del -r --purge buildDep \
    && rm -rf /var/cache/apk/* /tmp/* /root/.gnupg

# Create logging directories
RUN mkdir -p /var/log/ejabberd
RUN touch /var/log/ejabberd/crash.log /var/log/ejabberd/error.log /var/log/ejabberd/erlang.log

# Wrapper for setting config on disk from environment
# allows setting things like XMPP domain at runtime
ADD ./run.sh /sbin/run
RUN chmod +x /sbin/run

# Add run scripts
ADD ./scripts $EJABBERD_HOME/scripts
ADD https://raw.githubusercontent.com/rankenstein/ejabberd-auth-mysql/master/auth_mysql.py $EJABBERD_HOME/scripts/lib/auth_mysql.py
RUN chmod a+rx $EJABBERD_HOME/scripts/lib/auth_mysql.py
RUN chmod +x /usr/local/lib/eimp*/priv/bin/eimp

# Add config templates
ADD ./conf /opt/ejabberd/conf

# Continue as user
USER $EJABBERD_USER

# Set workdir to ejabberd root
WORKDIR $EJABBERD_HOME

VOLUME ["$EJABBERD_HOME/database", "$EJABBERD_HOME/ssl", "$EJABBERD_HOME/backup", "$EJABBERD_HOME/upload"]
EXPOSE 4560 5222 5269 5280 5443

CMD ["start"]
ENTRYPOINT ["run"]
