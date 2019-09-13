#!/bin/bash

if [ -z "$(command -v xdotool)" ]; then
    echo "xdotool required" >&2
    exit 1
fi

# Which key to press LMB=1, RMB=3, MMB=2
M="${M:-1}"
SD="${SD:-0.02}"
SU="${SU:-0.03}"
PIDFILE="${PIDFILE:-$XDG_RUNTIME_DIR/autoclicker$M}"

echo "pidfile: $PIDFILE"

if [ -e "$PIDFILE" ]; then
    kill -INT "$(cat "$PIDFILE")"
    exit
fi

echo $$ > "$PIDFILE"

run=true
trap 'run=false' INT

while $run; do
    xdotool mousedown "$M"
    sleep "$SD"
    xdotool mouseup "$M"
    sleep "$SU"
done

rm "$PIDFILE"
