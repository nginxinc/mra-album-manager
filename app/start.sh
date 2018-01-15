#!/bin/sh
NGINX_PID=${NGINX_PID:-"/var/run/nginx.pid"}    # /   (root directory)
NGINX_CONF=${NGINX_CONF:-"/etc/nginx/nginx.conf"}

rake db:migrate

APP=${APP:?"Please set the APP environment variable"}

if [ "$NETWORK" = "fabric" ]
then
    echo fabric configuration set;
fi

echo "Running ${APP}"

APP_PID=/var/run/unicorn.pid

if [  -f "$APP_PID" ]; then
    echo "Removing ${APP_PID}"
    rm -f $APP_PID
fi

$APP

nginx -c "$NGINX_CONF" -g "pid $NGINX_PID;"

sleep 30

while [ -f "$NGINX_PID" ] &&  [ -f "$APP_PID" ];
do
    sleep 5;
done
