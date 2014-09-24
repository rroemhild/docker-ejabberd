# Ejabberd 14.07

FROM ubuntu:14.04

MAINTAINER Rafael Römhild <rafael@roemhild.de>

# System update
RUN apt-get -qq update
RUN DEBIAN_FRONTEND=noninteractive apt-get -qqy install wget libyaml-0-2 \
    libexpat1 erlang-nox python-jinja2

# ejabberd
RUN wget -q -O /tmp/ejabberd-installer.run "http://www.process-one.net/downloads/downloads-action.php?file=/ejabberd/14.07/ejabberd-14.07-linux-x86_64-installer.run"
RUN chmod +x /tmp/ejabberd-installer.run
RUN /tmp/ejabberd-installer.run --mode unattended --prefix /opt/ejabberd --adminpw ejabberd

# config
ADD ./ejabberd.yml.tpl /opt/ejabberd/conf/ejabberd.yml.tpl
ADD ./ejabberdctl.cfg /opt/ejabberd/conf/ejabberdctl.cfg
RUN sed -i "s/ejabberd.cfg/ejabberd.yml/" /opt/ejabberd/bin/ejabberdctl

# wrapper for setting config on disk from environment
# allows setting things like XMPP domain at runtime
ADD ./run /opt/ejabberd/bin/run

# Add ejabberd user and group
RUN groupadd -r ejabberd \
    && useradd -r -g ejabberd -d /opt/ejabberd -s /usr/sbin/nologin ejabberd
RUN chown -R ejabberd:ejabberd /opt/ejabberd /.erlang.cookie
RUN sed -i "s/root/ejabberd/g" /opt/ejabberd/bin/ejabberdctl

# Clean up when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

USER ejabberd
VOLUME ["/opt/ejabberd/database"]
EXPOSE 5222 5269 5280
CMD ["live"]
ENTRYPOINT ["/opt/ejabberd/bin/run"]
