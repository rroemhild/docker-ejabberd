#!/bin/bash
set -e

source "${EJABBERD_ROOT}/bin/scripts/lib/config.sh"
source "${EJABBERD_ROOT}/bin/scripts/lib/functions.sh"


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


# generate config file
make_config
