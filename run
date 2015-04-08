#!/bin/bash
set -e

source "${EJABBERD_HOME}/bin/scripts/lib/config.sh"
source "${EJABBERD_HOME}/bin/scripts/lib/functions.sh"


## backward compatibility
# if ERLANG_NODE is true reset it to "ejabberd" and add
# hostname to the node.
is_true ${ERLANG_NODE} \
    && export ERLANG_NODE="ejabberd@${HOSTNAME}"


run_scripts() {
    local run_script_dir="${EJABBERD_HOME}/bin/scripts/${1}"
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


ctl() {
    local action="$1"
    ${EJABBERDCTL} ${action} >/dev/null
}


_trap() {
    echo "Stopping ejabberd..."
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

## scripts bevore starting ejabberd
pre_scripts

## run ejabberd
case "$@" in
    start)
        tail -F ${LOGDIR}/crash.log \
                ${LOGDIR}/error.log \
                ${LOGDIR}/erlang.log &
        echo "Starting ejabberd..."
        exec ${EJABBERDCTL} "live" &
        child=$!
        sleep 3
        post_scripts
        wait $child
    ;;
    live)
        echo "Starting ejabberd in 'live' mode..."
        exec ${EJABBERDCTL} "live"
    ;;
    shell)
        exec "/bin/bash"
    ;;
esac
