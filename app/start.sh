#!/bin/sh
NGINX_PID=${NGINX_PID:-"/var/run/nginx.pid"}    # /   (root directory)
NGINX_CONF=""

rake db:migrate

APP=${APP:?"Please set the APP environment variable"}

case "$NETWORK" in
    fabric)
        NGINX_CONF="/etc/nginx/fabric_nginx_$CONTAINER_ENGINE.conf"
        echo 'Fabric configuration set'
        nginx -c "$NGINX_CONF" -g "pid $NGINX_PID;" &
        ;;
    router-mesh)
        ;;
    *)
        echo 'Network not supported'
esac

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
