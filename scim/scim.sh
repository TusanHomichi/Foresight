#!/bin/sh
export XMODIFIERS="@im=SCIM"
export XIM_PROGRAM="/usr/bin/scim -d"
export GTK_IM_MODULE=scim
export QT_IM_MODULE=scim
scim -d &
