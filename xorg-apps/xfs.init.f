#!/bin/bash
#
# $Id:$
#
# xfs:       Starts the X Font Server
#
# Version:      @(#) /etc/init.d/xfs 2.0
#
# chkconfig: - 90 10
# description: Starts and stops the X Font Server at boot time and shutdown. \
#              It also takes care of (re-)generating font lists.
#
# processname: xfs
# config: /etc/X11/fs/config
# hide: true

# Source function library.
export LANG=C
. /etc/init.d/functions
# Set umask to ensure fonts.dir and similar files get created mode 0644
umask 133

prog=xfs

buildfontlist() {
   pushd . &> /dev/null
   # chkfontpath output filtering, strips all of the junk output by
   # chkfontpath that we do not want, including headers, FPE numbers and
   # whitespace and other junk.  Also filters out FPE's with trailing
   # modifiers such as ":unscaled" et al.
   for dir in $(/usr/sbin/chkfontpath --list | sed -e '/^Current/d;s#^[0-9]*: ##g;s#:unscaled$##g;/^[[:space:]]*$/d' | sort | uniq) ;do
      if [ -d "$dir" ]; then
         cd "$dir"
         # If fonts.dir does not exist, or if there are files in the
         # directory with a newer change time, regenerate fonts.dir, etc.
         # Using "-cnewer" here fixes bug #53737
         if [ ! -e fonts.dir ] || [ -n "$(find . -maxdepth 1 -type f -cnewer fonts.dir -not -name 'fonts.cache*' 2>/dev/null)" ]; then
            rm -f fonts.dir &>/dev/null
            if ls | grep -iqs '\.ot[cf]$' ; then
               # Opentype fonts found, generate fonts.scale and fonts.dir
               mkfontscale . && mkfontdir . &>/dev/null
            elif ls | grep -iqs '\.tt[cf]$' ; then
               # TrueType fonts found, generate fonts.scale and fonts.dir
               ttmkfdir -d . -o fonts.scale && mkfontdir . &>/dev/null
            elif ls | grep -Eiqsv '(^fonts\.(scale|alias|cache.*)$|.+(\.[ot]t[cf]|dir)$)' ; then
               # This directory contains non-TrueType/non-Opentype fonts
               mkfontdir . &>/dev/null
            fi
         fi
      fi
   done
   popd &> /dev/null
}

start() {
   FONT_UNIX_DIR=/tmp/.font-unix
   echo -n $"Starting $prog: "
   [ -x /usr/sbin/chkfontpath ] && buildfontlist
   # Clean out .font-unix dir, and recreate it with the proper ownership and
   # permissions.
   rm -rf $FONT_UNIX_DIR
   mkdir $FONT_UNIX_DIR
   chown root:root $FONT_UNIX_DIR
   chmod 1777 $FONT_UNIX_DIR
   # Fix needed for SELinux for bug (#130421,130969)
   [ -x /sbin/restorecon ] && /sbin/restorecon $FONT_UNIX_DIR

   daemon xfs -droppriv -daemon
   ret=$?
   [ $ret -eq 0 ] && touch /var/lock/subsys/xfs
   echo
   return $ret
}

stop() {
   echo -n $"Shutting down $prog: "
   killproc xfs
   ret=$?
   [ $ret -eq 0 ] && rm -f /var/lock/subsys/xfs
   echo
   return $ret
}

rhstatus() {
   status xfs
}

reload() {
   if [ -f /var/lock/subsys/xfs ]; then
      echo -n $"Reloading $prog: "
      [ -x /usr/sbin/chkfontpath ] && buildfontlist
      killproc xfs -USR1
      ret=$?
      echo
      return $ret
   else
      stop
      start
   fi
}

restart() {
   echo $"Restarting $prog:"
   stop
   start
}

condrestart() {
   # NOTE: We reload normally, to ensure the xfs<->Xserver connection does
   # not get broken on xfs upgrades, however we must force a restart on
   # upgrades that are migrating from monolithic Xorg (6.8.x or older) to
   # modular X, to avoid bug #173271.  The modular xfs %preun script will
   # now check for the old config file to determine if migration should be
   # done, and touch the following migration file if necessary.
   if [ -e /etc/X11/fs/xfs-migrate ] ; then
      restart
      rm -f /etc/X11/fs/xfs-migrate || : &> /dev/null
   else
      reload
   fi
}

case "$1" in
  start)
  start
  ;;
  stop)
  stop
  ;;
  restart)
    restart
    ;;
  reload)
  reload
  ;;
  condrestart)
  [ -f /var/lock/subsys/xfs ] && condrestart || :
  ;;
  status)
  rhstatus
  ;;
  *)
  echo $"Usage: $prog {start|stop|status|restart|reload|condrestart}"
  exit 1
esac

exit $?
