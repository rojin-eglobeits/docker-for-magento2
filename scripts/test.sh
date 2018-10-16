#!/usr/bin/env bash

set -e

project_dir=$PWD


source "${project_dir}/output_functions.sh"
source "${project_dir}/host/port-check.sh"
current_script_name=`basename "$0"`
initLogFile ${current_script_name}