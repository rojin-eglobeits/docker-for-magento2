#!/usr/bin/env bash

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