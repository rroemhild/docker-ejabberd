#!/bin/bash
set -e

source "${EJABBERD_HOME}/scripts/lib/base_config.sh"
source "${EJABBERD_HOME}/scripts/lib/config.sh"
source "${EJABBERD_HOME}/scripts/lib/base_functions.sh"
source "${EJABBERD_HOME}/scripts/lib/functions.sh"


get_cluster_node_from_dns() {
    local nodename=$(get_nodename)
    local cluster_host=$(drill ${DOMAINNAME} \
        | grep ${DOMAINNAME} \
        | grep -v ${HOSTIP} \
        | awk '{print $5}' \
        | grep -v "^$" \
        | head -1)

    echo $(discover_dns_hostname ${cluster_host})
}


join_cluster() {
    # local IFS=@

    local cluster_node=$(get_cluster_node_from_dns)

    is_zero ${cluster_node} \
        && exit 0

    echo "Join cluster..."

    # set ${ERLANG_NODE}
    local erlang_node_name=$(echo ${ERLANG_NODE} | cut -d "@" -f1)
    local erlang_cluster_node="${erlang_node_name}@${cluster_node}"

    response=$(${EJABBERDCTL} "ping ${erlang_cluster_node}")
    while [ "$response" != "pong" ]; do
        echo "Waiting for ${erlang_cluster_node}..."
        sleep 2
        response=$(${EJABBERDCTL} "ping ${erlang_cluster_node}")
    done

    echo "Join cluster at ${erlang_cluster_node}... "
    NO_WARNINGS=true ${EJABBERDCTL} join_cluster "$erlang_cluster_node"

    if [ $? -eq 0 ]; then
        touch ${CLUSTER_NODE_FILE}
    else
        echo "cloud not join cluster"
        exit 1
    fi
}


file_exist ${CLUSTER_NODE_FILE} \
    && exit 0


is_true ${EJABBERD_CLUSTER} \
    && join_cluster


exit 0
