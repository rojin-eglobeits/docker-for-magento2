#!/usr/bin/env bash

set -e

project_dir=$PWD

source "${project_dir}/scripts/output_functions.sh"
source "${project_dir}/scripts/host/port-check.sh"
current_script_name=`basename "$0"`
initLogFile ${current_script_name}

#Setiing configuration and reading it. if not exist instialize with config.yaml.dist
config_path="${project_dir}/etc/config.yaml"

if [[ ! -f "${config_path}" ]]; then
    while true; do
    	read -p "Do you wish to Initializing using config.yaml.dist ? Y/N " yn
    	case $yn in
        	[Yy]* ) answer=1 && break;;
        	[Nn]* ) status "Terminating Installation" && exit;;
        	* ) echo "Please answer yes or no.";;
    	esac
	done
	
	if [[ ${answer} == 1 ]]; then
		status "Initializing etc/config.yaml using defaults from etc/config.yaml.dist"
    	cp "${config_path}.dist" "${config_path}"
	fi
fi
project_name="$(bash "${project_dir}/scripts/get_config_value.sh" "project_name")"
checkout_source_from="$(bash "${project_dir}/scripts/get_config_value.sh" "checkout_source_from")"
#projeect code Directory
code_dir="${project_dir}/${project_name}"

#Clean up the Remove codebase if "-c" option was specified. New project if "-n" is used.
is_new_project=0
force_codebase_cleaning=0
force_phpstorm_config_cleaning=0
while getopts 'ncp' flag; do
  case "${flag}" in
    n) is_new_project=1 ;;
    c) force_codebase_cleaning=1 ;;
    p) force_phpstorm_config_cleaning=1 ;;
    *) error "Unexpected option" && exit 1;;
  esac
done

#functions To be moved to function.sh file in feature

#checkout code from git
function checkoutSourceCodeFromGit(){
if [[ ! -d ${code_dir} ]]; then
        initMagento2Git
        initMagento2SampleGit
    fi
}
#init magento2 git
function initMagento2Git()
{
    repository_url_m2="$(bash "${project_dir}/scripts/get_config_value.sh" "repository_url_m2")"
    initGitRepository ${repository_url_m2} "${project_name}" "${code_dir}"
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


if [[ ${force_codebase_cleaning} -eq 1 ]]; then
    status "Removing current Magento codebase before initialization since '-c' option was used"
    #rm -rf "${code_dir}"
fi

if [[ ! -d ${code_dir} ]]; then
    if [[ (${is_new_project} -eq 1 ) && ("${checkout_source_from}" == "composer") ]]; then
        #composerCreateProject
        success "Project cloning successfully completed.."
    elif [[ "${checkout_source_from}" == "git" ]]; then
        checkoutSourceCodeFromGit
        success "Project cloning successfully completed.."
    else
        error "Value specified for 'checkout_source_from' is invalid. Supported options: composer OR git"
        exit 1
    fi
fi



if [[ -d ${code_dir} ]]; then
    success "Project cloning successfully completeeeeeeeeed.."
   # startDocker
   # installMagento2
fi