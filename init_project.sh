#!/usr/bin/env bash

set -e

project_dir=$PWD
source "${project_dir}/scripts/output_functions.sh"
source "${project_dir}/scripts/host/port-check.sh"

resetNestingLevel
current_script_name=`basename "$0"`
initLogFile ${current_script_name}

config_path="${project_dir}/etc/config.yaml"
if [[ ! -f "${config_path}" ]]; then
    status "Initializing etc/config.yaml using defaults from etc/config.yaml.dist"
    cp "${config_path}.dist" "${config_path}"
fi
project_name="$(bash "${project_dir}/scripts/get_config_value.sh" "project_name")"
magento_bin_dir="${project_dir}/bin"
magento2_dir="${project_dir}/${project_name}"
magento2_sample_data_dir="${magento2_dir}/magento2ce-sample-data"
repository_url_m2="$(bash "${project_dir}/scripts/get_config_value.sh" "repository_url_m2")"
composer_project_name="$(bash "${project_dir}/scripts/get_config_value.sh" "composer_project_name")"
composer_project_url="$(bash "${project_dir}/scripts/get_config_value.sh" "composer_project_url")"
checkout_source_from="$(bash "${project_dir}/scripts/get_config_value.sh" "checkout_source_from")"

host_name="$(bash "${project_dir}/scripts/get_config_value.sh" "magento_host_name")"
function checkoutSourceCodeFromGit()
{
    if [[ ! -d ${magento2_dir} ]]; then
        
        initMagento2Git
        initMagento2SampleGit
    fi
}

function initMagento2Git()
{
    echo  ${project_name}
    initGitRepository ${repository_url_m2} "${project_name}" "${magento2_dir}"
}

function initMagento2SampleGit()
{
    repository_url_m2_sample_data="$(bash "${project_dir}/scripts/get_config_value.sh" "repository_url_m2_sample_data")"
    initGitRepository ${repository_url_m2_sample_data} "Magento2 sample data" "${magento2_sample_data_dir}"
}

# Initialize the cloning and checkout of a git repository
# Arguments:
#   Url of repository
#   Name of repository (CE, EE)
#   Directory where the repository will be cloned to
function initGitRepository()
{
    local repository_url=${1}
    local repository_name=${2}
    local directory=${3}

    if [[ ${repository_url} == *"::"* ]]; then
        local branch=$(getGitBranch ${repository_url})
        local repo=$(getGitRepository ${repository_url})
    else
        local repo=${repository_url}
    fi

    status "Checking out ${project_name} repository"
    git clone ${repo} "${directory}" --progress 2> >(logError) > >(log)

    if [[ -n ${branch} ]]; then
        status "Checking out branch ${branch} of ${project_name} repository"
        cd "${directory}"
        git fetch 2> >(logError) > >(log)
        git checkout ${branch} 2> >(log) > >(log)
    fi
    cd "${project_dir}"
}

# Get the git repository from a repository_url setting in config.yaml
function getGitRepository()
{
    local repo="${1%::*}" # Gets the substring before the '::' characters
    echo ${repo}
}

# Get the git branch from a repository_url setting in config.yaml
function getGitBranch()
{
    local branch="${1#*::}" # Gets the substring after the '::' characters
    echo ${branch}
}

function composerCreateProject()
{
    if [[ ! -d ${magento2_dir} ]]; then
        status "Downloading Magento codebase using 'composer create-project'"
        bash "${project_dir}/scripts/host/composer.sh" create-project ${composer_project_name} "${magento2_dir}" --repository-url=${composer_project_url}

        # TODO: Workaround for Magento 2.2+ until PHP is upgraded to 7.1 on the guest
        cd "${magento2_dir}"
        composer_dir="${project_dir}/scripts/host"
        composer_phar="${composer_dir}/composer.phar"
        php_executable="$(bash "${project_dir}/scripts/host/get_path_to_php.sh")"
        project_version="$("${php_executable}" "${composer_phar}" show --self | grep version)"
        matching_version_pattern='2.[23].[0-9]+'
        if [[ ${project_version} =~ ${matching_version_pattern} ]]; then
            status "Composer require zendframework/zend-code:~3.1.0 (needed for Magento 2.2+ only)"
            cd "${magento2_dir}"
            bash "${project_dir}/scripts/host/composer.sh" require "zendframework/zend-code:~3.1.0"
        fi
    fi
}

function startDocker()
{
    # install docker if not installed or throw error 
    status "Starting Docker containers...."
    docker-compose up -d

}
function installMagento2()
{
    bash "$magento_bin_dir/console.sh" install "${host_name}"
}
# Clean up the project before initialization if "-f" option was specified. Remove codebase if "-fc" is used.
force_project_cleaning=0
force_codebase_cleaning=0
force_phpstorm_config_cleaning=0
while getopts 'fcp' flag; do
  case "${flag}" in
    f) force_project_cleaning=1 ;;
    c) force_codebase_cleaning=1 ;;
    p) force_phpstorm_config_cleaning=1 ;;
    *) error "Unexpected option" && exit 1;;
  esac
done
if [[ ${force_project_cleaning} -eq 1 ]]; then
    status "Cleaning up the project before initialization since '-f' option was used"
    if [[ ${force_codebase_cleaning} -eq 1 ]]; then
        status "Removing current Magento codebase before initialization since '-c' option was used"
        rm -rf "${magento2_dir}"
    fi
fi

if [[ ! -d ${magento2_dir} ]]; then
    if [[ "${checkout_source_from}" == "composer" ]]; then
        composerCreateProject
        success "Project cloning successfully completed.."
    elif [[ "${checkout_source_from}" == "git" ]]; then
        checkoutSourceCodeFromGit
        success "Project cloning successfully completed.."
    else
        error "Value specified for 'checkout_source_from' is invalid. Supported options: composer OR git"
        exit 1
    fi
fi



if [[ -d ${magento2_dir} ]]; then
    startDocker
    installMagento2
fi  

