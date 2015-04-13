FROM rroemhild/ejabberd:latest
ENV EJABBERD_HOME /opt/ejabberd
ENV ETCD_URL http://172.17.42.1:4001/v2/keys

ADD ./scripts $EJABBERD_HOME/scripts

USER root

###
# Workaround https://github.com/processone/ejabberd/issues/498
ENV SPOOL_DIR=/var/lib/ejabberd
RUN rm /lib/ejabberd/priv/bin/joincluster \
    && rm /lib/ejabberd/priv/bin/leavecluster
ADD joincluster /sbin/joincluster
ADD leavecluster /sbin/leavecluster
RUN sed -i "s/\$EJABBERD_BIN_PATH\/joincluster/\/sbin\/joincluster/g" /sbin/ejabberdctl
RUN sed -i "s/\$EJABBERD_BIN_PATH\/leavecluster/\/sbin\/leavecluster/g" /sbin/ejabberdctl
RUN sed -i '/export ERL_MAX_ETS_TABLES/a export KERNEL_OPTS' /sbin/ejabberdctl
RUN sed -i '/export ERL_MAX_ETS_TABLES/a export SPOOL_DIR' /sbin/ejabberdctl
# Workaround end
###

# RUN sed -i "s/read foo//" /sbin/joincluster
# RUN sed -i "s/read foo//" /sbin/leavecluster

USER ejabberd
