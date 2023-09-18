if [ "$PS1" ]; then
  D="/etc/bash_completion.d"
  if [ -f "$D"/hg ]; then
    . "$D"/hg
  fi
  unset D
fi
