#!/bin/sh
#
# xdm:       Starts the X Display Manager (gdm / kdm / xdm)
#
# Version:      @(#) /etc/init.d/xdm 1.3
#
# chkconfig: 5 18 82
# description: Starts and stops the X Display Manager at startup and shutdown.
# can run one of several display managers; gdm, kdm, or xdm, in that order of
# preferential treatment.
#
# config: /etc/X11/xdm/xdm-config
# probe: true
# hide: true

ICE_DIR=/tmp/.ICE-unix

##export LANG=C
# Source function library.
. /etc/init.d/functions

case "$1" in
  start)
	#echo "bogus start"
	echo
	;;
  stop)
	#echo "bogus stop"
	echo 
	;;
  status)
	# echo "bogus status"
	echo 
	;;
  restart)
	# echo "bogus restart"
	echo
	;;
  probe)
	# echo "bogus probe"
	ech 
	;;
    *)
	echo 
	exit 1
esac

exit 0
