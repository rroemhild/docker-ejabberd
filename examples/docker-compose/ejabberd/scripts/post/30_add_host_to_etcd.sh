#!/bin/bash
set -e

source "${EJABBERD_HOME}/scripts/lib/config.sh"
source "${EJABBERD_HOME}/scripts/lib/functions.sh"
source "${EJABBERD_HOME}/scripts/lib/cluster.sh"


etcd_register_host() {
    # register node in etcd for skydns
    local etcd="${ETCD_URL}${ETCD_SKYDNS_DOMAIN_PATH}"
    echo "Register ${HOST_NAME} in etcd..."
    curl --silent -L -X PUT ${etcd}/${HOST_NAME} \
        -d value='{"host":"'${HOST_IP}'","port":4369}'
}


etcd_register_host
unlock_ejabberd_join_cluster

exit 0
