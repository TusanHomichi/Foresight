#!/bin/bash
# chkconfig: 345 80 20
# description: Gunicorn WSGI HTTP server

# Source function library.
. /etc/rc.d/init.d/functions

prog=$(basename $0)
[ ${prog:0:1} = "S" -o ${prog:0:1} = "K" ] && prog=${prog:3}

pidfile=/var/run/${prog}.pid
lockfile=/var/lock/subsys/${prog}
sysconf=/etc/sysconfig/${prog}
STOP_TIMEOUT=3
GUNICORN="/usr/bin/python -Wignore /usr/bin/gunicorn"
GUNICORN_ARGS=

[ -f $sysconf ] && . $sysconf

RETVAL=0

start() {
        echo -n $"Starting $prog: "
        if [ -z "$GUNICORN_ARGS" ]
        then
            failure "gunicorn start"
            echo
            echo "You must set GUNICORN_ARGS in $sysconf"
            RETVAL=1
            return $RETVAL
        fi
        daemon --pidfile ${pidfile} ${GUNICORN} -D -p "$pidfile" ${GUNICORN_ARGS}
        RETVAL=$?
        echo
        [ $RETVAL = 0 ] && touch ${lockfile}
        return $RETVAL
}

stop() {
        echo -n $"Stopping $prog: "
        killproc -p ${pidfile} -d ${STOP_TIMEOUT} $prog
        RETVAL=$?
        echo
        [ $RETVAL = 0 ] && rm -f ${lockfile} ${pidfile}
}

reload() {
        echo -n $"Reloading $prog: "
        killproc -p ${pidfile} $prog -HUP
        echo
}

# See how we were called.
case "$1" in
  start)
        start
        ;;
  stop)
        stop
        ;;
  status)
        status -p ${pidfile} $prog
        RETVAL=$?
        ;;
  restart)
        stop
        start
        ;;
  condrestart|try-restart)
        if status -p ${pidfile} $prog >&/dev/null; then
                stop
                start
        fi
        ;;
  reload)
        reload
        ;;
  condreload)
        if status -p ${pidfile} $prog >&/dev/null; then
                reload
        fi
        ;;
  rotate)
        [ -f $pidfile ] && kill -USR1 $(cat $pidfile)
        ;;
  *)
        echo $"Usage: $prog {start|stop|restart|condrestart|reload|condreload|rotate|status|help}"
        RETVAL=2
esac

exit $RETVAL
