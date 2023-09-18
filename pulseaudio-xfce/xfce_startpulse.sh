#!/bin/sh
pulseaudio -D --high-priority
pactl load-module module-x11-xsmp
