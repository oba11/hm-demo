#!/bin/sh
set -e

# Get IP address
if [ -f "/etc/environment" ]; then
    export ADVERTISE_IP=$(awk -F= '/COREOS_PUBLIC_IPV4/ {print $2}' /etc/environment)
fi

if [ -z $ADVERTISE_IP ]; then
    export ADVERTISE_IP=$(ip route get 8.8.8.8 | awk 'NR==1 {print $NF}')
fi

# Start Nginx
/usr/sbin/nginx

# Continue the script
exec /bin/consul-template -consul ${ADVERTISE_IP}:8500 -template "/config/nginx.ctmpl:/etc/nginx/conf.d/default.conf:nginx -s reload"
