FROM rroemhild/ejabberd:15.06

ENV EJABBERD_HOME /opt/ejabberd
ENV ETCD_URL http://172.17.42.1:4001/v2/keys

USER root

RUN apt-get update \
    && apt-get install -y curl \
    && rm -rf /var/lib/apt/lists/*

COPY ./scripts $EJABBERD_HOME/scripts

# Workarround leavecluster bug
RUN sed -i 's/^exit//' /lib/ejabberd/priv/bin/leavecluster

# Workarround ejabberdctl bindir
RUN sed -i 's/EPMD=\/\/bin\/epmd/EPMD=\/usr\/bin\/epmd/' /sbin/ejabberdctl

USER ejabberd
