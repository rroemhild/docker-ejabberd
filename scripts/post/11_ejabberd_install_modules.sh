#!/bin/bash
set -e

# Installs modules as defined in environment variables

source "${EJABBERD_HOME}/scripts/lib/base_config.sh"
source "${EJABBERD_HOME}/scripts/lib/config.sh"
source "${EJABBERD_HOME}/scripts/lib/base_functions.sh"
source "${EJABBERD_HOME}/scripts/lib/functions.sh"

install_module_from_source() {
    local module_name=$1
    local module_source_path=${EJABBERD_HOME}/module_source/${module_name}
    local module_install_folder=${EJABBERD_HOME}/.ejabberd-modules/sources/${module_name}
    
    echo "Analyzing module ${module_name} for installation"
    # Make sure that the module exists in the source folder before attempting a copy

    if [ ! -d ${module_source_path} ]; then
        echo "Error: Module ${module_name} not found in ${EJABBERD_HOME}/module_source"
        echo "Please use a shared volume to populate your module in ${EJABBERD_HOME}/module_source"
        return 1;
    fi

    # Check to see if the module is already installed
    local install_count=$(${EJABBERDCTL} modules_installed | grep -ce "^${module_name}[[:space:]]")
    if [ $install_count -gt 0 ]; then
        echo "Error: Module already installed: ${module_name}"
        return 1;
    fi

    # Copy the module into the shared folder
    echo "Copying module to ejabberd folder ${module_install_folder}"
    cp -R ${module_source_path} ${module_install_folder}

    # Run the ejabberdctl module_check on the module
    echo "Running module_check on ${module_name}"
    ${EJABBERDCTL} module_check ${module_name}
    if [ $? -ne 0 ]; then
        echo "Module check failed for ${module_name}"
        return 1;
    fi
    echo "Module check succeeded for ${module_name}"

    # Install the module
    echo "Running module_install on ${module_name}"
    ${EJABBERDCTL} module_install ${module_name}
    if [ $? -ne 0 ]; then
        echo "Module installation failed for ${module_name}"
        return 1;
    fi
    echo "Module installation succeeded for ${module_name}"

    return 0;
}

install_module_from_ejabberd_contrib() {
    local module_name=$1

    # Check to see if the module is already installed
    local install_count=$(${EJABBERDCTL} modules_installed | grep -ce "^${module_name}[[:space:]]")
    if [ $install_count -gt 0 ]; then
        echo "Error: Module already installed: ejabberd_contrib ${module_name}"
        return 1;
    fi

    # Install the module
    echo "Running module_install on ejabberd_contrib ${module_name}"
    ${EJABBERDCTL} module_install ${module_name}
    if [ $? -ne 0 ]; then
        echo "Module installation failed for ejabberd_contrib ${module_name}"
        return 1;
    fi
    echo "Module installation succeeded for ejabberd_contrib ${module_name}"

    return 0;
}

file_exist ${FIRST_START_DONE_FILE} \
    && exit 0

did_modules_install=0;

if [ -n "${EJABBERD_SOURCE_MODULES}" ]; then
    for module_name in ${EJABBERD_SOURCE_MODULES} ; do
        install_module_from_source ${module_name}
    done
    did_modules_install=1;
fi

# Check the EJABBERD_CONTRIB_MODULES variable for any ejabberd_contrib modules
if [ -n "${EJABBERD_CONTRIB_MODULES}" ]; then
    for module_name in ${EJABBERD_CONTRIB_MODULES} ; do
        install_module_from_ejabberd_contrib ${module_name}
    done
    did_modules_install=1;
fi

# If any modules were installed, restart the server, if the option is enabled
if [ ${did_modules_install} -eq 1 ]; then
    if is_true ${EJABBERD_RESTART_AFTER_MODULE_INSTALL} ; then
        echo "Restarting ejabberd after successful module installation(s)"
        ${EJABBERDCTL} restart
    fi
fi

exit 0