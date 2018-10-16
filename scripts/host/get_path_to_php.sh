#!/usr/bin/env bash

cd "$(dirname "${BASH_SOURCE[0]}")/../.." && project_dir=$PWD

source "${project_dir}/scripts/output_functions.sh"
incrementNestingLevel

# Find path to available PHP
if [[ -f "${project_dir}/lib/php/php.exe" ]]; then
    php_executable="${project_dir}/lib/php/php"
else
    php_executable="php"
fi
echo ${php_executable}

decrementNestingLevel
