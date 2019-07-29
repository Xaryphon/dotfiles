#!/bin/sh

if [ "$BLOCK_INSTANCE" ]; then
    alias playerctl='playerctl -p "$BLOCK_INSTANCE"'
fi

status="$(playerctl status)"

if [ "$status" = "Not available" ]; then
    exit 0
fi

if [ "4" = "$BLOCK_BUTTON" ]; then
    playerctl volume 0.05+
elif [ "5" = "$BLOCK_BUTTON" ]; then
    playerctl volume 0.05-
fi

vol="$(playerctl volume)"
vol="$(echo "${vol}*100" | bc | awk '{print int($1+0.5)}')"

printf "%s%%" "${vol}"
exit 0
