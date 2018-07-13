#!/bin/sh
NGINX_PID=${NGINX_PID:-"/var/run/nginx.pid"}    # /   (root directory)
NGINX_CONF=""
APP="unicorn -c /usr/src/app/unicorn.rb -D"

rake db:migrate

echo "Running ${APP}"

APP_PID=/var/run/unicorn.pid

if [ -f "$APP_PID" ]; then
    echo "Removing ${APP_PID}"
    rm -f ${APP_PID}
fi

${APP} &

sleep 30

case "$NETWORK" in
    fabric)
        NGINX_CONF="/etc/nginx/fabric_nginx_$CONTAINER_ENGINE.conf"
        echo 'Fabric configuration set'
        nginx -c "$NGINX_CONF" -g "pid $NGINX_PID;" &

        sleep 10

        while [ -f "$NGINX_PID" ] &&  [ -f "$APP_PID" ];
        do
            sleep 5;
        done
        ;;
    router-mesh)
        while [ -f "$APP_PID" ];
        do
            sleep 5;
        done
        ;;
    proxy)
        while [ -f "$APP_PID" ];
        do
            sleep 5;
        done
        ;;
    *)
        echo 'Network not supported'
        exit 1
esac
