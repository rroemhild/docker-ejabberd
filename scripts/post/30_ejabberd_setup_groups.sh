#!/bin/bash
set -e

source "${EJABBERD_HOME}/scripts/lib/base_config.sh"
source "${EJABBERD_HOME}/scripts/lib/config.sh"
source "${EJABBERD_HOME}/scripts/lib/base_functions.sh"
source "${EJABBERD_HOME}/scripts/lib/functions.sh"


create_group() {
    local group=$1
    local host=$2

    echo "Creating roster group: ${group}@${host}"
    # Do not exit if group already registered
    ${EJABBERDCTL} srg_create ${group} ${host} ${group} '' ${group} || true
}

register_group_member() {
    local user=$1
    local host=$2
    local group=$3
    local grouphost=$4

    echo "Adding ${user} ${host} to roster group ${group}@${grouphost}"
    # Do not exit if user is already a member
    ${EJABBERDCTL} srg_user_add ${user} ${host} ${group} ${grouphost} || true
}


register_all_groups() {
    # register shared roster groups from environment $EJABBERD_GROUPS
    # Use whitespace to seperate groups.
    #
    # sample:
    # - create two groups:
    #   -e "EJABBERD_GROUPS=admin@example.com test@example.com"
    for group in ${EJABBERD_GROUPS} ; do
        local name=${group%%@*}
        local host=${group#*@}

        create_group ${name} ${host}
    done
}

register_all_group_members() {
    # register shared roster group members from environment $EJABBERD_GROUP_MEMBERS
    # Use whitespace to seperate groups.
    #
    # sample:
    # - add two users to groups:
    #   -e "EJABBERD_GROUP_MEMBERS=user@xmpp.kx.gd:group@xmpp.kx.gd user2@xmpp.kx.gd:group@xmpp.kx.gd"

    for member in ${EJABBERD_GROUP_MEMBERS} ; do
        local user=${member%%:*}
        local group=${member#*:}

        local username=${user%@*}
        local userhost=${user##*@}

        local groupname=${group%@*}
        local grouphost=${group##*@}

        register_group_member ${username} ${userhost} ${groupname} ${grouphost}
    done
}


file_exist ${FIRST_START_DONE_FILE} \
    && exit 0

is_set ${EJABBERD_GROUPS} \
    && register_all_groups

is_set ${EJABBERD_GROUP_MEMBERS} \
    && register_all_group_members

exit 0
