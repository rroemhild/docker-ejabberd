is_set() {
    local var=$1

    [[ -n $var ]]
}


is_zero() {
    local var=$1

    [[ -z $var ]]
}


file_exist() {
    local file=$1

    [[ -e $file ]]
}


is_true() {
    local var=${1,,}
    local choices=("yes" "1" "y" "true")
    for ((i=0;i < ${#choices[@]};i++)) {
        [[ "${choices[i]}" == $var ]] && return 0
    }
    return 1
}


get_nodename() {
    local hostname=${HOSTNAME}

    # get hostname from dns
    is_true ${USE_DNS} \
        && hostname=$(discover_dns_hostname)

    retval=$?

    echo $hostname
    return $retval
}


discover_dns_hostname() {
    # discover hostname from dns with a reverse lookup.
    # else set to local hostname

    # wait for dns registration
    sleep 1

    # try to get the hostname from dns
    local dnsname=$(drill -x ${HOSTIP} \
        | grep PTR \
        | awk '{print $5}' \
        | grep -E "^[a-zA-Z0-9]+([-._]?[a-zA-Z0-9]+)*.[a-zA-Z]+\.$" \
        | tail -1 \
        | cut -d '.' -f 1)

    if (is_set ${dnsname}); then
        echo ${dnsname}
        return 0
    else
        echo ${HOSTNAME}
        return 1
    fi
}
