FROM debian:7
MAINTAINER Rafael Römhild <rafael@roemhild.de>

ENV EJABBERD_BRANCH 15.04
ENV EJABBERD_USER ejabberd
ENV EJABBERD_WEB_ADMIN_SSL true
ENV EJABBERD_STARTTLS true
ENV EJABBERD_S2S_SSL true
ENV EJABBERD_HOME /opt/ejabberd
ENV HOME $EJABBERD_HOME
ENV PATH $EJABBERD_HOME/bin:/usr/sbin:/usr/bin:/sbin:/bin
ENV DEBIAN_FRONTEND noninteractive
ENV XMPP_DOMAIN localhost

# Add ejabberd user and group
RUN groupadd -r $EJABBERD_USER \
    && useradd -r -m \
       -g $EJABBERD_USER \
       -d $EJABBERD_HOME \
       -s /usr/sbin/nologin \
       $EJABBERD_USER

# Add erlang repository
RUN echo 'deb http://packages.erlang-solutions.com/debian wheezy contrib' >> \
        /etc/apt/sources.list \
    && apt-key adv \
        --keyserver keys.gnupg.net \
        --recv-keys 434975BD900CCBE4F7EE1B1ED208507CA14F4FCA

# Install requirements
RUN apt-get update \
    && apt-get -y --no-install-recommends install \
        locales \
        curl \
        git-core \
        build-essential \
        automake \
        libssl-dev \
        libyaml-dev \
        zlib1g-dev \
        libexpat-dev \
        python2.7 \
        python-jinja2 \
        ca-certificates \
        libsqlite3-dev \
        erlang-base erlang-snmp erlang-ssl erlang-ssh erlang-webtool \
        erlang-tools erlang-xmerl erlang-corba erlang-diameter erlang-eldap \
        erlang-eunit erlang-ic erlang-inviso erlang-odbc erlang-os-mon \
        erlang-parsetools erlang-percept erlang-typer erlang-src erlang-dev \
    && rm -rf /var/lib/apt/lists/*

# Install program to configure locales
RUN dpkg-reconfigure locales && \
        locale-gen C.UTF-8 \
    && /usr/sbin/update-locale LANG=C.UTF-8

# Install needed default locale for Makefly
RUN echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen \
    && locale-gen

# Set default locale for the environment
ENV LC_ALL C.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8

# Install ejabberd from source
RUN cd /tmp \
    && git clone https://github.com/processone/ejabberd.git \
        --branch $EJABBERD_BRANCH --single-branch --depth=1 \
    && cd ejabberd \
    && chmod +x ./autogen.sh \
    && ./autogen.sh \
    && ./configure --enable-user=$EJABBERD_USER \
        --enable-all \
        --disable-tools \
        --disable-pam \
    && make \
    && make install \
    && mkdir $EJABBERD_HOME/ssl \
    && mkdir $EJABBERD_HOME/conf \
    && mkdir $EJABBERD_HOME/database \
    && cd $EJABBERD_HOME \
    && rm -rf /tmp/ejabberd \
    && rm -rf /etc/ejabberd \
    && ln -sf $EJABBERD_HOME/conf /etc/ejabberd \
    && chown -R $EJABBERD_USER: $EJABBERD_HOME

# Wrapper for setting config on disk from environment
# allows setting things like XMPP domain at runtime
ADD ./run.sh /sbin/run

# Add run scripts
ADD ./scripts $EJABBERD_HOME/scripts

# Add config templates
ADD ./conf /opt/ejabberd/conf

# Continue as user
USER $EJABBERD_USER

# Set workdir to ejabberd root
WORKDIR $EJABBERD_HOME

VOLUME ["$EJABBERD_HOME/database", "$EJABBERD_HOME/ssl"]
EXPOSE 4560 5222 5269 5280

CMD ["start"]
ENTRYPOINT ["run"]
