#!/usr/bin/env sh

#
# Copyright (c) 2006 rPath, Inc.
# This file is distributed under the terms of the MIT License.
# A copy is available at http://www.rpath.com/permanent/mit-license.html
#

CERTPATH=/etc/ssl/certs
PEMPATH=/etc/ssl/pem
PRIVATEPATH=/etc/ssl/private

function basename()
{
   local name="${1##*/}"
   echo "${name%$2}"
}

function dirname()
{
   local dir="${1%${1##*/}}"
   [ "${dir:=./}" != "/" ] && dir="${dir%?}"
   echo "$dir"
}

function ext()
{
   local name=${1##*/}
   local name0="${name%.*}"
   local ext=${name0:+${name#$name0}}
   echo "${ext:-.}"
}


# Take two parameters:
if [ "$#" -lt 1 ]; then
    echo $"Usage: gendummycert {file.pem} | {file.key} {file.crt}"
    exit 1
fi

keyfile=$1

#if we're generating a pem, then use a single file, and dump it to the pemdir
if [ $(ext $keyfile) = '.pem' ]; then
    CERTPATH=$PEMPATH
    PRIVATEPATH=$PEMPATH
fi

if [ -n "$2" ]; then
    crtfile=$2
else
    crtfile=$keyfile
fi

#Check to make sure it's not a qualified path already
if [ $(basename $keyfile) = "$keyfile" ] ; then
    keyfile=$PRIVATEPATH/$keyfile
fi
if [ $(basename $crtfile) = "$crtfile" ] ; then
    crtfile=$CERTPATH/$crtfile
fi

#Make the directories if they don't exist
keypath=$(dirname $keyfile)
if [ ! -d $keypath ] ; then
    mkdir -p $keypath
fi
crtpath=$(dirname $crtfile)
if [ ! -d $crtpath ] ; then
    mkdir -p $crtpath
fi

#Check to make sure the files don't exist already
if [ -f $crtfile -o -f $keyfile ]; then
    exit 0
fi

FQDN=$(if [ -z "$(hostname)" ] ; then echo "localhost.localdomain" ; else hostname ; fi)

UMASK=$(umask)
umask 077
/usr/bin/openssl genrsa 1024 -text > $keyfile 2>/dev/null
#If the keyfile and crtfile are different, go ahead and reset the umask so that public key is world readable
if [ "$keyfile" != "$crtfile" ] ; then
    umask $UMASK
else
    echo >>$keyfile
fi
#this uses the default values stored in openssl.cnf except for hostname and e-mail
cat <<EOF | /usr/bin/openssl req -new -key $keyfile -text -x509 -days 365 >>$crtfile 2>/dev/null





$FQDN
root@$FQDN
EOF
umask $UMASK

