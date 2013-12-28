# Ejabberd 13.12
#
# VERSION 0.1

FROM ubuntu
MAINTAINER Rafael Römhild <rafael@roemhild.de>

RUN apt-get update
RUN apt-get -y dist-upgrade
RUN apt-get -y install curl build-essential m4 git libncurses5-dev libssh-dev libyaml-dev libexpat-dev

# Erlang
RUN mkdir -p /src/erlang \
&& cd /src/erlang \
&& curl http://erlang.org/download/otp_src_R16B03.tar.gz > otp_src_R16B03.tar.gz \
&&  tar xf otp_src_R16B03.tar.gz \
&& cd otp_src_R16B03 \
&& ./configure \
&& make \
&& make install

# Ejabberd
RUN mkdir -p /src/ejabberd \
&& cd /src/ejabberd \
&& curl -L "http://www.process-one.net/downloads/downloads-action.php?file=/ejabberd/13.12/ejabberd-13.12.tgz" > ejabberd-13.12.tgz \
&& tar xf ejabberd-13.12.tgz \
&& cd ejabberd-13.12 \
&& ./configure \
&& make \
&& make install

# Cleanup
RUN cd / && rm -rf /src
RUN apt-get -y purge curl build-essential m4 git libncurses5-dev libssh-dev libyaml-dev libexpat-dev

# Copy config
RUN rm /etc/ejabberd/ejabberd.yml
ADD ejabberd.yml /etc/ejabberd/

EXPOSE 5222 5269 5280
CMD ["live"]
ENTRYPOINT ["ejabberdctl"]
