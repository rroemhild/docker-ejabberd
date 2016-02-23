#!/bin/bash
set -e

# Installs modules as defined in environment variables

source "${EJABBERD_HOME}/scripts/lib/base_config.sh"
source "${EJABBERD_HOME}/scripts/lib/config.sh"
source "${EJABBERD_HOME}/scripts/lib/base_functions.sh"
source "${EJABBERD_HOME}/scripts/lib/functions.sh"

copy_and_check_module() {
    local module_name=$1
    local module_source_path=${EJABBERD_HOME}/module_source/${module_name}
    local module_install_folder=${EJABBERD_HOME}/.ejabberd-modules/sources/${module_name}
    
    echo "Attempting to install module ${module_name}"
    if file_exist ${module_source_path} ; then
        cp -R ${module_source_path} ${module_install_folder}
        
        ${EJABBERDCTL} module_check ${module_name}
        local retval=$?

        if [ ${retval} -ne 0 ]; then
            echo "Module check failed for ${module_name}"
        else 
            echo "Module check succeeded for ${module_name}"
        fi
    else 
        echo "Module ${module_name} not found in ${EJABBERD_HOME}/module_source. Skipping installation."
    fi

    return $?
}

install_module() {
    local module_name=$1

    ${EJABBERDCTL} module_install ${module_name}
    local retval=$?
    if [ ${retval} -ne 0 ]; then
        echo "Module installation failed for ${module_name}"
    else 
        echo "Module installation succeeded for ${module_name}"
    fi

    return $?
}

for module_name in ${EJABBERD_SOURCE_MODULES} ; do
    copy_and_check_module ${module_name}
    retval=$?
    if [ ${retval} -eq 0 ]; then
        install_module ${module_name}
    fi

    if is_true ${EJABBERD_RESTART_AFTER_MODULE_INSTALL} ; then
       ${EJABBERDCTL} restart
    fi
done

exit 0
