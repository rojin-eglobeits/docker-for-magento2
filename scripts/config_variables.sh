#!/usr/bin/env bash

project_name="$(bash "${project_dir}/scripts/get_config_value.sh" "project_name")"
magento_bin_dir="${project_dir}/bin"
project_code_dir="${project_dir}/${project_name}"
magento2_sample_data_dir="${magento2_dir}/magento2ce-sample-data"
repository_url_m2="$(bash "${project_dir}/scripts/get_config_value.sh" "repository_url_m2")"
composer_project_name="$(bash "${project_dir}/scripts/get_config_value.sh" "composer_project_name")"
composer_project_url="$(bash "${project_dir}/scripts/get_config_value.sh" "composer_project_url")"
checkout_source_from="$(bash "${project_dir}/scripts/get_config_value.sh" "checkout_source_from")"

host_name="$(bash "${project_dir}/scripts/get_config_value.sh" "magento_host_name")"