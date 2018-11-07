#!/bin/bash
set -e

gosu root chown -R ${EJABBERD_USER}: ${EJABBERD_HOME}

exit 0
