#!/bin/bash
set -e

# Updates the known modules as to be found in https://github.com/processone/ejabberd-contrib

source "${EJABBERD_ROOT}/bin/scripts/lib/config.sh"
source "${EJABBERD_ROOT}/bin/scripts/lib/functions.sh"

run_modules_update_specs() {
    echo -n 'Updating module specs... '
    ${EJABBERDCTL} modules_update_specs
}

is_set ${EJABBERDCTL} \
    && run_modules_update_specs

exit 0
