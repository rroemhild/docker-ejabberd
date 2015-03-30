#!/bin/bash
#set -e

# Sample script to register admin user(s)
# enable: chmod +x 20_ejabberd_register_admin.sh

source "${EJABBERD_ROOT}/bin/scripts/lib/config.sh"
source "${EJABBERD_ROOT}/bin/scripts/lib/functions.sh"


randpw() {
    < /dev/urandom tr -dc A-Z-a-z-0-9 | head -c${1:-16};
    echo;
}

register_admin() {
    local username=$1
    local domain=$2
    local password=$(randpw)

    $EJABBERDCTL register admin $XMPP_DOMAIN password1234
    local retval=$?

    [[ $retval -eq 0 ]] && echo "Registered admin user: '${username}@${domain}' password: '${password}'" >> ${LOGDIR}/erlang.log
}


register_admin admin $XMPP_DOMAIN
