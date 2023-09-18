#!/bin/sh

branch=$(grep -m 1 ^branch CONARY)
date=$(date +%Y.%m.%d-%H:%M.%S)
touch $date.log
ln -sf $date.log log 
case $branch in
  */2-devel)
    BRANCH="foresight.rpath.org@fl:2-devel"
    CONTEXT="fl:2-devel"
    ;;
  */2-qa)
    BRANCH="foresight.rpath.org@fl:2-qa"
    CONTEXT="fl:2-qa"
    ;;
  */2)
    echo "DO NOT COOK ON STABLE LABEL!  SEE promote SCRIPT INSTEAD!"
    exit 1
    ;;
  *)
    echo "WHERE ARE YOU?"
    exit 1
    ;;
esac

#time cvc cook --context $CONTEXT --build-label=$BRANCH group-desktop-platform.recipe'[~!bootstrap,~!builddocs,~!dom0,~!domU,~!vmware,~!xen is: x86]' 2> log2
time cvc cook --context $CONTEXT --build-label=$BRANCH group-desktop-platform=$BRANCH'[~!bootstrap,~!builddocs,~!dom0,~!domU,~!vmware,~!xen  is: x86 x86_64]' group-desktop-platform=$BRANCH'[~!bootstrap,~!builddocs,~!dom0,~!domU,~!vmware,~!xen is: x86]'  --allow-flavor-change  --debug=all 2>&1 |tee $date.log
date +%Y.%m.%d-%k:%m.S
