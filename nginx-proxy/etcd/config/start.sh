#!/bin/sh
set -e

# Start Nginx
/usr/sbin/nginx

# Continue the script
exec "$@"
