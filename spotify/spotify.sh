#!/bin/sh

# board=http://community.spotify.com/t5/Desktop-Linux

# $board/ANNOUNCE-Spotify-0-8-3-for-GNU-Linux/td-p/60659/page/6
rm -f \$HOME/.cache/spotify/offline.bnk

# $board/Illegal-Instruction-Client-Crash-Read-Here/td-p/194448
cat /proc/cpuinfo | grep -q 'sse2' || {
    zenity --error --text "Cannot run on this CPU (no sse2 support)"
    exit 1
}

if [[ $( uname -r ) == *x86_64 ]]; then
    LD_LIBRARY_PATH=%(libdir)s/spotify-client/:${LD_LIBRARY_PATH} %(datadir)s/spotify-client/spotify $@
else
    LD_LIBRARY_PATH=%(libdir)s/spotify-client/:${LD_LIBRARY_PATH} %(datadir)s/spotify-client/spotify $@
fi


