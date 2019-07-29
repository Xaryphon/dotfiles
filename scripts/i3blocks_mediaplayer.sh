#!/bin/sh

if [ "$BLOCK_INSTANCE" ]; then
    alias playerctl='playerctl -p "$BLOCK_INSTANCE"'
fi

status="$(playerctl status)"

if [ "$status" = "Not available" ]; then
    exit 0
fi

if [ "1" = "$BLOCK_BUTTON" ]; then
    playerctl previous
elif [ "2" = "$BLOCK_BUTTON" ]; then
    playerctl play-pause
elif [ "3" = "$BLOCK_BUTTON" ]; then
    playerctl next
fi

statuss=""

if [ "$status" = "Stopped" ]; then
    statuss=""
elif [ "$status" = "Paused" ]; then
    statuss=""
elif [ "$status" = "Playing" ]; then
    statuss=""
else
    statuss="?"
fi

artist="$(playerctl metadata artist)"
song="$(playerctl metadata title)"

printf "%s  %s - %s" "${statuss}" "${artist}" "${song}"
exit 0
