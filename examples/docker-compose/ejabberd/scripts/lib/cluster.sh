readonly HOST_IP=$(hostname -i)
readonly HOST_NAME=$(hostname -s)
readonly ETCD_EJABBERD_ROOT="/ejabberd"
readonly ETCD_EJABBERD_CLUSTER="${ETCD_EJABBERD_ROOT}/cluster"

readonly PYTHON_JSON_NODE_VALUE="import sys;
import json;
try:
    obj=json.load(sys.stdin);
    values = obj['node']['value']
    values = json.loads(values)
    print values['status']
except:
    sys.exit(0)"


ETCD_SKYDNS_DOMAIN_PATH=""
set_skydns_domain_path() {
    local domain=$(grep search /etc/resolv.conf | cut -d' ' -f2)
    local domain_path="/skydns"
    local domain_array=""
    if [ "$domain" != "" ] ; then
        IFS=. read -a domain_array <<< "${domain}"
        for (( idx=${#domain_array[@]}-1 ; idx>=0 ; idx-- )) ; do
            domain_path="${domain_path}/${domain_array[idx]}"
        done
    fi
    ETCD_SKYDNS_DOMAIN_PATH=${domain_path}
}

set_skydns_domain_path


is_ejabberd_cluster_locked() {
    local etcd="${ETCD_URL}${ETCD_EJABBERD_CLUSTER}/status"
    local status=$(curl -s ${etcd} \
        | python -c "${PYTHON_JSON_NODE_VALUE}")
    if [ "$status" == "locked" ] ; then
        return 0
    fi

    return 1
}


lock_ejabberd_join_cluster() {
    local etcd="${ETCD_URL}${ETCD_EJABBERD_CLUSTER}/status"
    echo "${HOST_NAME} locks join_cluster.."
    curl --silent -L -X PUT "${etcd}" \
        -d value='{"status":"locked","host":"'${HOST_NAME}'"}'
}


unlock_ejabberd_join_cluster() {
    local etcd="${ETCD_URL}${ETCD_EJABBERD_CLUSTER}/status"
    echo "${HOST_NAME} unlocks join_cluster.."
    curl --silent -L -X DELETE "${etcd}"
}
