#!/bin/bash
#set -e

source "${EJABBERD_HOME}/scripts/lib/base_config.sh"
source "${EJABBERD_HOME}/scripts/lib/config.sh"
source "${EJABBERD_HOME}/scripts/lib/base_functions.sh"
source "${EJABBERD_HOME}/scripts/lib/functions.sh"


etcd_unregister_host() {
    # register node in etcd for skydns
    local etcd="${ETCD_URL}${ETCD_SKYDNS_DOMAIN_PATH}"
    echo "Unregister ${HOST_NAME} in etcd..."
    curl --silent -L -X DELETE ${etcd}/${HOST_NAME}
}


leave_cluster() {
    echo "Leave cluster... "
    NO_WARNINGS=true ${EJABBERDCTL} leave_cluster
}


set_skydns_domain_path
etcd_unregister_host
leave_cluster

exit 0
