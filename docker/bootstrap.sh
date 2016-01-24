#!/bin/sh
set -e

readonly EJABBERD_VERSION="16.01"
readonly EJABBERD_DEB_PKG_VERSION="0"

# install dependencies
export DEBIAN_FRONTEND="noninteractive"
apt-get update \
    && apt-get install -yq \
        wget \
	    locales \
        ldnsutils \
        ca-certificates \
        libyaml-0-2 \
        libexpat1 \
        libltdl7 \
        libodbc1 \
        libsctp1 \
        python2.7 \
        python-jinja2 \
        imagemagick \
    && rm -rf /var/lib/apt/lists/*

# add ejabberd user
useradd -M ejabberd
usermod -d $EJABBERD_HOME ejabberd

# install ejabberd from .deb package
wget -qO /tmp/ejabberd.deb https://www.process-one.net/downloads/downloads-action.php?file=/ejabberd/$EJABBERD_VERSION/ejabberd_${EJABBERD_VERSION}-${EJABBERD_DEB_PKG_VERSION}_amd64.deb
dpkg -i /tmp/ejabberd.deb
rm /tmp/ejabberd.deb

# rename installdir and symlink new to orig
mv "$EJABBERD_HOME-$EJABBERD_VERSION" $EJABBERD_HOME
ln -s $EJABBERD_HOME "$EJABBERD_HOME-$EJABBERD_VERSION"

# rename configs
mv $EJABBERD_HOME/conf/ejabberd.yml \
    $EJABBERD_HOME/conf/ejabberd.yml.orig
mv $EJABBERD_HOME/conf/ejabberdctl.cfg \
    $EJABBERD_HOME/conf/ejabberdctl.cfg.orig

# add exported dirs
mkdir $EJABBERD_HOME/ssl
mkdir $EJABBERD_HOME/backup
mkdir $EJABBERD_HOME/upload
mkdir -p $EJABBERD_HOME/modules/conf

# remove logs
rm $EJABBERD_HOME/logs/*.log
