#!/bin/bash

if [ $# -lt 2 ]; then
    echo "not enough arguments: $0 $*" >&2
    exit 1
fi

type="$1"
shift
action="$1"
shift

case $type in
    files)
	# skip input to avoid parent getting SIGPIPE
	cat >/dev/null

	case $action in
	    update|remove)
                # The script may emit errors during normal operation.
                python%(pyver)s -c 'from twisted.plugin import IPlugin, getPlugins; list(getPlugins(IPlugin))' >&/dev/null
		;;
	esac
	;;
esac

exit 0
