#!/bin/bash
set -e

# Environment
export EJABBERD_HTTPS="true"
export EJABBERD_STARTTLS="true"
export EJABBERD_S2S_SSL="true"

source "${EJABBERD_HOME}/docker/lib/base_config.sh"
source "${EJABBERD_HOME}/docker/lib/config.sh"
source "${EJABBERD_HOME}/docker/lib/base_functions.sh"
source "${EJABBERD_HOME}/docker/lib/functions.sh"

# discover hostname
readonly nodename=$(get_nodename)

# set erlnag node to node name from get_nodename
if [[ "$ERLANG_NODE" == "nodename" ]]; then
    export ERLANG_NODE="ejabberd@${nodename}"
fi


run_scripts() {
    local run_script_dir="${EJABBERD_HOME}/docker/${1}"
    for script in ${run_script_dir}/*.sh ; do
        if [ -f ${script} -a -x ${script} ] ; then
            ${script}
        fi
    done
}


pre_scripts() {
    run_scripts "pre"
}


post_scripts() {
    run_scripts "post"
}

stop_scripts() {
    run_scripts "stop"
}


ctl() {
    local action="$1"
    ${EJABBERDCTL} ${action} >/dev/null
}


_trap() {
    log "Stopping ejabberd..."
    stop_scripts
    if ctl stop ; then
        local cnt=0
        sleep 1
        while ctl status || test $? = 1 ; do
            cnt=`expr $cnt + 1`
            if [ $cnt -ge 60 ] ; then
                break
            fi
            sleep 1
        done
    fi
}


# Catch signals and shutdown ejabberd
trap _trap SIGTERM SIGINT

log "Run pre scripts..."
pre_scripts

# print logfiles to stdout
tail -F ${LOGDIR}/crash.log \
        ${LOGDIR}/error.log \
        ${LOGDIR}/erlang.log \
        ${LOGDIR}/ejabberd.log &

log "Starting ejabberd..."
ctl start

sleep 2
# ctl started

log "Run post scripts..."
post_scripts

while ctl status || test $? = 0; do
    sleep 1
done

log "Ejabberd stopped"
stop_scripts

exit 0
