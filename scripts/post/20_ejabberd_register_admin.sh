#!/bin/bash
#set -e

# Sample script to register admin user(s)

source "${EJABBERD_HOME}/scripts/lib/base_config.sh"
source "${EJABBERD_HOME}/scripts/lib/config.sh"
source "${EJABBERD_HOME}/scripts/lib/base_functions.sh"
source "${EJABBERD_HOME}/scripts/lib/functions.sh"


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


register_all_ejabberd_admins() {
    # add all admins from environment $EJABBERD_ADMIN with the passwords from
    # environment $EJABBERD_ADMIN_PASS.

    local passwords
    local IFS=' '
    read -a passwords <<< "${EJABBERD_ADMIN_PWD}"

    for admin in ${EJABBERD_ADMIN} ; do
        local user=${admin%%@*}
        local domain=${admin#*@}
        local password=${passwords[0]}
        passwords=("${passwords[@]:1}")
        register_admin ${user} ${domain} ${password}
    done
}


register_all_ejabberd_admins_randpw() {
    # add all admins from environment $EJABBERD_ADMIN with a random
    # password and write the password to stdout.

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


file_exist ${FIRST_START_DONE_FILE} \
    && exit 0


file_exist ${CLUSTER_NODE_FILE} \
    && exit 0


is_set ${EJABBERD_ADMIN_PWD} \
    && register_all_ejabberd_admins


is_true ${EJABBERD_ADMIN_RANDPWD} \
    && register_all_ejabberd_admins_randpw


exit 0
