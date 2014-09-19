# Ejabberd 14.07

FROM ubuntu:14.04

MAINTAINER Rafael Römhild <rafael@roemhild.de>

# System update
RUN apt-get -y update
RUN apt-get -y dist-upgrade
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install wget libyaml-0-2 libexpat1

# erlang
RUN wget -q -O /tmp/erlang-solutions_1.0_all.deb http://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb
RUN dpkg -i /tmp/erlang-solutions_1.0_all.deb
RUN apt-get -y update
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install erlang-nox

# ejabberd
RUN wget -q -O /tmp/ejabberd-installer.run "http://www.process-one.net/downloads/downloads-action.php?file=/ejabberd/14.07/ejabberd-14.07-linux-x86_64-installer.run"
RUN chmod +x /tmp/ejabberd-installer.run
RUN /tmp/ejabberd-installer.run --mode unattended --prefix /opt/ejabberd --adminpw ejabberd

# copy config
#RUN rm /opt/ejabberd/conf/ejabberd.cfg
ADD ./ejabberd.yml /opt/ejabberd/conf/ejabberd.yml
ADD ./ejabberdctl.cfg /opt/ejabberd/conf/ejabberdctl.cfg

RUN sed -i "s/ejabberd.cfg/ejabberd.yml/" /opt/ejabberd/bin/ejabberdctl

EXPOSE 5222 5269 5280
CMD ["live"]
ENTRYPOINT ["/opt/ejabberd/bin/ejabberdctl"]
