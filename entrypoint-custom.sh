#!/bin/sh

envsubst < /usr/share/nginx/html/web-config-template.js > /usr/share/nginx/html/web-config.js

#Call original nginx entrypoint script
exec /docker-entrypoint.sh "$@"
