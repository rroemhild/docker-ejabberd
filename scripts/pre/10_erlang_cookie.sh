#!/bin/bash
set -e

source "${EJABBERD_ROOT}/bin/scripts/lib/config.sh"
source "${EJABBERD_ROOT}/bin/scripts/lib/functions.sh"


set_erlang_cookie() {
    echo "Set erlang cookie to ${ERLANG_COOKIE}..."
    echo ${ERLANG_COOKIE} > ${ERLANGCOOKIEFILE}
    chmod 400 ${ERLANGCOOKIEFILE}
}


## backward compatibility
# if ERLANG_NODE is true reset it to "ejabberd" and add
# hostname to the node.
is_true ${ERLANG_NODE} \
    && export ERLANG_NODE="ejabberd@${HOSTNAME}"


# set erlang cookie if ERLANG_COOKIE is set in environemt
is_set ${ERLANG_COOKIE} \
    && set_erlang_cookie
