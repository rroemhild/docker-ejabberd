#!/bin/bash
set -e

source "${EJABBERD_HOME}/scripts/lib/base_config.sh"
source "${EJABBERD_HOME}/scripts/lib/config.sh"
source "${EJABBERD_HOME}/scripts/lib/base_functions.sh"
source "${EJABBERD_HOME}/scripts/lib/functions.sh"


NODE_HOSTNAME=""
get_random_cluster_node() {
    local etcd="${ETCD_URL}${ETCD_SKYDNS_DOMAIN_PATH}"
    NODE_HOSTNAME=$(curl -s ${etcd} \
        | python -c "${PYTHON_JSON_NODE_KEYS}" \
        | rev \
        | cut -d '/' -f 1 \
        | rev \
        | shuf \
        | head -1)
}


join_cluster() {
    local IFS=@

    get_random_cluster_node

    is_zero "${NODE_HOSTNAME}" \
       && exit 0

    set ${ERLANG_NODE}
    local erlang_node_name=$1
    local cluster_node="${erlang_node_name}@${NODE_HOSTNAME}"
    echo "Join cluster at ${cluster_node}... "
    NO_WARNINGS=true ${EJABBERDCTL} join_cluster "${cluster_node}"
}


is_ejabberd_cluster_locked
locked=$?
while [ $locked -eq 0 ] ; do
    sleep_time=$(($RANDOM % 45  + 15))
    echo "Wait ${sleep_time} seconds bevor join_cluster..."
    sleep 15
    is_ejabberd_cluster_locked
    locked=$?
done


set_skydns_domain_path
lock_ejabberd_join_cluster
join_cluster

exit 0
