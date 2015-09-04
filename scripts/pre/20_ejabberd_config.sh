#!/bin/bash
set -e

source "${EJABBERD_HOME}/scripts/lib/base_config.sh"
source "${EJABBERD_HOME}/scripts/lib/config.sh"
source "${EJABBERD_HOME}/scripts/lib/base_functions.sh"
source "${EJABBERD_HOME}/scripts/lib/functions.sh"


make_config() {
    echo "Generating ejabberd config file..."
    cat ${CONFIGTEMPLATE} \
      | python -c "${PYTHON_JINJA2}" \
      > ${CONFIGFILE}

    echo "Generating ejabberdctl config file..."
    cat ${CTLCONFIGTEMPLATE} \
      | python -c "${PYTHON_JINJA2}" \
      > ${CTLCONFIGFILE}
}


file_exist ${FIRST_START_DONE_FILE} \
    && exit 0


# generate config file
make_config

exit 0
