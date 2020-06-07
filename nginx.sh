#!/bin/bash
# 
# nginx+php-fpm for web server.
#
# chkconfig: - 50 50
# description: nginx web server and php fastcgi service control.
#
### BEGIN INIT INFO
# Provides:          nginx
# Required-Start:    $network
# Short-Description: Initializes nginx+php-fpm
# Description:       Initializes nginx+php-fpm for web server.
### END INIT INFO

root=/opt/lnmp

nginx=$root/sbin/nginx
ngpid=$root/logs/nginx.pid

phpfpm=$root/sbin/php-fpm
phppid=$root/var/run/php-fpm.pid

. /etc/init.d/functions

function statprog() {
    pidfile=$1
    program=$2
    if [ -f "$pidfile" ]; then
        pid=$(cat $pidfile)
        if [ $pid -gt 0 -a -d "/proc/$pid" -a "$(cat /proc/$pid/comm)"="$program" ]; then
            echo $program is running.
            return 0
        fi
    fi
    echo $program is not running.
    return 1
}

case "$1" in
    "start")
        $nginx
        $phpfpm -g $phppid -D
        ;;
    "stop")
        $nginx -s stop
        killproc -p $phppid
        ;;
    "restart")
        $0 stop
        $0 start
        ;;
    "status")
        statprog $ngpid nginx
        statprog $phppid php-fpm
        ;;
    "reload")
        $nginx -t && $nginx -s reload
        ;;
    *)
        # usage
        basename=`basename "$0"`
        echo "Usage: $basename  {start|stop|restart|reload|status}  [ Nginx+php-fpm server options ]"
        exit 1
        ;;
esac

