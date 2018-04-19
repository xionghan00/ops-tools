#!/bin/sh

export CATALINA_HOME=/usr/java/apache-tomcat-7.0.65
export JAVA_OPTS="$JAVA_OPTS -server -Xms4g -Xmx4g -XX:PermSize=64m"




##############################################################################################
export CATALINA_BASE=$(cd `dirname $0`; pwd)

start() {
    if [ -f $CATALINA_HOME/bin/startup.sh ]; then
        $CATALINA_HOME/bin/startup.sh
    fi
}

stop() {
    if [ -f $CATALINA_HOME/bin/shutdown.sh ]; then
        $CATALINA_HOME/bin/shutdown.sh
    fi
}

restart() {
    echo "[INFO] instance stopping..."
    stop;

    try_time=10
    while [ "X`ps -ef | grep java | grep "Dcatalina.base=$CATALINA_BASE" | grep -v grep`" != "X" ];
    do
        let try_time=$try_time-1
        if [ $try_time -eq 0 ]; then
            pid=`ps -ef | grep java | grep "Dcatalina.base=$CATALINA_BASE" | grep -v grep | awk '{print $2}'`
            echo "force kill process $pid"
            kill -9 $pid
            break
        fi

        echo "time count $try_time..."
        sleep 1;
    done

    echo "[INFO] starting instance..."
    start;
}


case "$1" in
    start)
        start;
    ;;
    stop)
        stop;
    ;;
    restart)
        restart;
    ;;
    *)
        echo $"Usage: $0 {start | stop | restart}"
        exit 1
    ;;
esac
