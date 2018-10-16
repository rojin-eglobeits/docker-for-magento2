#!/usr/bin/env bash

set -e

project_dir=$PWD

source "${project_dir}/scripts/output_functions.sh"
source "${project_dir}/scripts/host/port-check.sh"
current_script_name=`basename "$0"`
initLogFile ${current_script_name}

#Setiing configuration and reading it. if not exist instialize with config.yaml.dist
source "${project_dir}/scripts/config_variables.sh"
config_path="${project_dir}/etc/config.yaml"

if [[ ! -f "${config_path}" ]]; then
    while true; do
        read -p "Do you wish to Initializing using config.yaml.dist ? Y/N " yn
        case $yn in
            [Yy]*) answer=1 && break ;;
            [Nn]*) status "Terminating Installation" && exit ;;
            *) echo "Please answer yes or no." ;;
        esac
    done

    if [[ ${answer} == 1 ]]; then
        status "Initializing etc/config.yaml using defaults from etc/config.yaml.dist"
        cp "${config_path}.dist" "${config_path}"
    fi
fi

#Clean up the Remove codebase if "-c" option was specified. New project if "-n" is used.
is_new_project=0
force_codebase_cleaning=0
force_phpstorm_config_cleaning=0
while getopts 'ncp' flag; do
    case "${flag}" in
        n) is_new_project=1 ;;
        c) force_codebase_cleaning=1 ;;
        p) force_phpstorm_config_cleaning=1 ;;
        *) error "Unexpected option" && exit 1 ;;
    esac
done

#functions
source "${project_dir}/scripts/host/host_functions.sh"


if [[ ${force_codebase_cleaning} -eq 1 ]]; then
    status "Removing current Magento codebase before initialization since '-c' option was used"
    rm -rf "${project_code_dir}"
fi

if [[ ! -d ${project_code_dir} ]]; then
    if [[ ( ${is_new_project} -eq 1 ) && ( "${checkout_source_from}" == "composer" ) ]]; then
        #composerCreateProject
        success "Project cloning successfully completed.."
    elif [[ "${checkout_source_from}" == "git" ]]; then
        #checkoutSourceCodeFromGit
        success "Project cloning successfully completed.."
    else
        error "Value specified for 'checkout_source_from' is invalid. Supported options: composer OR git"
        exit 1
    fi
fi



if [[ -d ${project_code_dir} ]]; then
    success "Project cloning successfully completeeeeeeeeed.."
# startDocker
# installMagento2
fi