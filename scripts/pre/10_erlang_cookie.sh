#!/bin/bash
set -e

source "${EJABBERD_HOME}/bin/scripts/lib/config.sh"
source "${EJABBERD_HOME}/bin/scripts/lib/functions.sh"


set_erlang_cookie() {
    echo "Set erlang cookie to ${ERLANG_COOKIE}..."
    chmod 644 ${ERLANGCOOKIEFILE}
    echo ${ERLANG_COOKIE} > ${ERLANGCOOKIEFILE}
    chmod 400 ${ERLANGCOOKIEFILE}
}


# set erlang cookie if ERLANG_COOKIE is set in environemt
is_set ${ERLANG_COOKIE} \
    && set_erlang_cookie

exit 0
