#!/bin/bash
set -e

source "${EJABBERD_HOME}/scripts/lib/base_config.sh"
source "${EJABBERD_HOME}/scripts/lib/config.sh"
source "${EJABBERD_HOME}/scripts/lib/base_functions.sh"
source "${EJABBERD_HOME}/scripts/lib/functions.sh"


etcd_register_host() {
    # register node in etcd for skydns
    local etcd="${ETCD_URL}${ETCD_SKYDNS_DOMAIN_PATH}"
    echo "Register ${HOST_NAME} in etcd..."
    curl --silent -L -X PUT ${etcd}/${HOST_NAME} \
        -d value='{"host":"'${HOST_IP}'","port":4369}'
}


set_skydns_domain_path
etcd_register_host
unlock_ejabberd_join_cluster

exit 0
