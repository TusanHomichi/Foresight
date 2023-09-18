#!/bin/sh
#
# When using SDL with virt-manager/libvirt, SDL needs access to the Xauth cookie.
#
# But since GDM now puts this cookie in a random file in /var/run/gdm, we need
# to provide a stable symlink in each user's home directory for each session.
#
# Note that this will probably break in the corner case where a user
# who is already logged into an X session logs into another X session
# while using the same $HOME directory.

# xhost trickery might also do it (documented here for completeness)
# xhost +SI:localgroup:kvm

# make a ~/.Xauthority symlink since that's what libvirt will configure
# by default when using an SDL Display

if [ -n "$XAUTHORITY" ]; then
  ln -sf "$XAUTHORITY" "$HOME/.Xauthority"
fi

