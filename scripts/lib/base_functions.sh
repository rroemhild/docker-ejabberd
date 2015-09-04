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
    if ( is_true ${USE_DNS} ); then
        # wait for dns registration
        sleep 1

        nodename=$(discover_dns_hostname ${HOSTIP})

        is_set ${nodename} \
            && hostname=${nodename}
    fi

    echo $hostname
    return 0
}


discover_dns_hostname() {
    # discover hostname from dns with a reverse lookup.

    local hostip=$1

    # try to get the hostname from dns
    local dnsname=$(drill -x ${hostip} \
        | grep PTR \
        | awk '{print $5}' \
        | grep -E "^[a-zA-Z0-9]+([-._]?[a-zA-Z0-9]+)*.[a-zA-Z]+\.$" \
        | cut -d '.' -f1 \
        | tail -1)

    is_set ${dnsname} \
        && echo ${dnsname}

    return 0
}
