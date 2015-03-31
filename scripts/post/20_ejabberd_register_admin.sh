#!/bin/bash
#set -e

# Sample script to register admin user(s)

source "${EJABBERD_ROOT}/bin/scripts/lib/config.sh"
source "${EJABBERD_ROOT}/bin/scripts/lib/functions.sh"


randpw() {
    < /dev/urandom tr -dc A-Z-a-z-0-9 | head -c ${1:-16};
    echo;
}


register_admin() {
    local user=$1
    local domain=$2
    local password=$3

    ${EJABBERDCTL} register ${user} ${domain} ${password}
    return $?
}


register_all_xmpp_admins() {
    # add all admins from environment $EJABBERD_ADMIN with a random
    # password and write the password to stdout

    for admin in ${EJABBERD_ADMIN} ; do
        local user=${admin%%@*}
        local domain=${admin#*@}
        local password=$(randpw)

        register_admin ${user} ${domain} ${password}
        local retval=$?

        [[ ${retval} -eq 0 ]] \
            && echo "Password for user ${user}@${domain} is ${password}"
    done
}


is_true ${EJABBERD_AUTO_ADMIN} \
    && register_all_xmpp_admins

exit 0
