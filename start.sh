#!/bin/sh
NGINX_PID=${NGINX_PID:-"/var/run/nginx.pid"}    # /   (root directory)
NGINX_CONF=${NGINX_CONF:-"/etc/nginx/nginx.conf"}
NGINX_FABRIC=${NGINX_FABRIC:="/etc/nginx/nginx-fabric.conf"}

APP=${APP:?"Please set the APP environment variable"}

if [ "$NETWORK" = "fabric" ]
then
    NGINX_CONF=$NGINX_FABRIC;
    echo This is the nginx conf = $NGINX_CONF;
    echo fabric configuration set;
fi

$APP

nginx -c "$NGINX_CONF" -g "pid $NGINX_PID;"

service amplify-agent start

sleep 30
APP_PID=/var/run/unicorn.pid

while [ -f "$NGINX_PID" ] &&  [ -f "$APP_PID" ];
do
	sleep 5;
done
