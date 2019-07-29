#!/bin/sh

alias sed='sed --sandbox -En'

SINK="$BLOCK_INSTANCE"
if ! [ "$SINK" ]; then
    SINK="$(pactl info | sed "/Default Sink: /s/^.*?: (.*)/\1/p")"
fi

get_sink_index() {
    # get_sink_index sink
    # sink: Name of the sink you want to get the index for.
    if [ $# -ne 1 ]; then
        echo "get_sink_index: too few arguments" >&2
    fi
    sink="$1"
    pactl list short sinks | sed "/^[[:digit:]]+[[:space:]]+$sink\b/="
}

get_sink_volume() {
    # get_sink_volume sink_index
    # sink_index: Index of the sink you want to get the volume for.
    if [ $# -ne 1 ]; then
        echo "get_sink_volume: too few arguments" >&2
    fi
    sink_index="$1"
    pactl list sinks | sed "/^[[:space:]]Volume/s/.*? ([[:digit:]]{0,3})%.*?/\1/p" | sed "${sink_index}p"
}

SINK_INDEX="$(get_sink_index "$SINK")"
SINK_VOLUME="$(get_sink_volume "$SINK_INDEX")"

if [ "$BLOCK_BUTTON" = 4 ]; then
    SINK_VOLUME="$((SINK_VOLUME + 5))"
    pactl set-sink-volume "$SINK" "$SINK_VOLUME%"
elif [ "$BLOCK_BUTTON" = 5 ]; then
    SINK_VOLUME="$((SINK_VOLUME - 5))"
    pactl set-sink-volume "$SINK" "$SINK_VOLUME%"
fi

printf "%s%%" "$SINK_VOLUME"
exit 0
