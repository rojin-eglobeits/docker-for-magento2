#!/usr/bin/env bash

cd "$(dirname "${BASH_SOURCE[0]}")/../.." && project_dir=$PWD

source "${project_dir}/scripts/output_functions.sh"

status "Installing PHP"
incrementNestingLevel

host_os="$(bash "${project_dir}/scripts/host/get_host_os.sh")"

if [[ ${host_os} == "Windows" ]]; then
    curl http://windows.php.net/downloads/releases/archives/php-5.6.9-nts-Win32-VC11-x86.zip -o "${project_dir}/lib/php.zip" 2> >(log) > >(log)
    unzip -q "${project_dir}/lib/php.zip" -d "${project_dir}/lib/php" 2> >(log) > >(log)
    rm -f "${project_dir}/lib/php.zip"
    cp "${project_dir}/lib/php/php.ini-development" "${project_dir}/lib/php/php.ini"
    sed -i.back 's|; extension_dir = "ext"|extension_dir = "ext"|g' "${project_dir}/lib/php/php.ini"
    sed -i.back 's|;extension=php_openssl.dll|extension=php_openssl.dll|g' "${project_dir}/lib/php/php.ini"
    rm -rf "${project_dir}/lib/php/*.back"
fi

php_executable="$(bash "${project_dir}/scripts/host/get_path_to_php.sh")"
if ! ${php_executable} -v 2> >(log) | grep -q 'Copyright' ; then
    error "Automatic PHP installation is not available for your host OS. Please install any version of PHP to allow Magento dependencies management using Composer. Check out http://php.net/manual/en/install.php"
    decrementNestingLevel
    exit 1
else
    success "PHP installed successfully"
fi

decrementNestingLevel
