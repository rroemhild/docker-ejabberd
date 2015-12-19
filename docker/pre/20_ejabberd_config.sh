#!/bin/bash
set -e

source "${EJABBERD_HOME}/docker/lib/base_config.sh"
source "${EJABBERD_HOME}/docker/lib/config.sh"
source "${EJABBERD_HOME}/docker/lib/base_functions.sh"
source "${EJABBERD_HOME}/docker/lib/functions.sh"


make_config() {
    local filename=$1
    local template="${CONFIGTMPDIR}/${filename}.tpl"
    local configfile="${CONFIGDIR}/${filename}"

    log "Generating ${configfile} from template..."
    cat $template \
      | python -c "${PYTHON_JINJA2}" \
      > $configfile
}


file_exist ${FIRST_START_DONE_FILE} \
    && exit 0


# /opt/ejabberd/conf/ejabberd.yml
make_config "ejabberd.yml"

# /opt/ejabberd/conf/ejabberdctl.cfg
make_config "ejabberdctl.cfg"


exit 0
