#!/bin/bash
set -e

source "${EJABBERD_ROOT}/bin/scripts/lib/config.sh"
source "${EJABBERD_ROOT}/bin/scripts/lib/functions.sh"


set_erlang_cookie() {
    echo "Set erlang cookie to ${ERLANG_COOKIE}..."
    echo ${ERLANG_COOKIE} > ${ERLANGCOOKIEFILE}
    chmod 400 ${ERLANGCOOKIEFILE}
}


# set erlang cookie if ERLANG_COOKIE is set in environemt
is_set ${ERLANG_COOKIE} \
    && set_erlang_cookie

exit 0
