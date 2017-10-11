#!/bin/bash
set -e

source "${EJABBERD_HOME}/scripts/lib/base_config.sh"
source "${EJABBERD_HOME}/scripts/lib/config.sh"
source "${EJABBERD_HOME}/scripts/lib/base_functions.sh"
source "${EJABBERD_HOME}/scripts/lib/functions.sh"

write_file_from_files() {
    echo "Writing $1 to $2"
    mkdir -p "$(dirname $2)"
    gosu root cat ${!1} > $2
}

# Write the host certificate
is_set ${EJABBERD_SSLCERT_HOST_PATH} \
  && write_file_from_files "EJABBERD_SSLCERT_HOST_PATH" ${SSLCERTHOST}

# Write the domain certificates for each XMPP_DOMAIN
for xmpp_domain in ${XMPP_DOMAIN} ; do
    var="EJABBERD_SSLCERT_$(echo $xmpp_domain | awk '{print toupper($0)}' | sed 's/\./_/g;s/-/_/g')_PATH"
    if is_set ${!var} ; then
        write_file_from_files "$var" "${SSLCERTDIR}/${xmpp_domain}.pem"
    fi
done

exit 0
