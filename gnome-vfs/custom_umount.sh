#! /bin/sh
DEV=$(grep $1 /etc/mtab |grep -o '^[^" "]*')
echo $DEV
#UDI=`lshal 2>/dev/null|grep -B 400 $DEV\' |grep ^udi|tail -1|sed "s/.*'\(.*\)'/\1/"`
#EJECT=`hal-get-property --udi $UDI --key storage.requires_eject`
#UMOUNT=`hal-get-property --udi $UDI --key volume.is_mounted`
#if $UMOUNT; then
pumount $1
#fi
#if $EJECT;then
#eject $DEV
#fi
