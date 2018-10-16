#!/usr/bin/env bash

set -e

ports=(80 443 3309 8181 6379)
info "Checking Necessary ports are free in host..."
for port in ${ports[@]};
do
	
	if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null ; then
    error "Port $port is used by host machine.Please either stop the service using the port or change the port" && exit;
	fi
done
status "Port Checking completed...."