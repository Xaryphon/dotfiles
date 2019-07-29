#!/bin/sh

alias sed='sed --sandbox -En'

SINK="$BLOCK_INSTANCE"
if ! [ "$SINK" ]; then
    SINK="$(pactl info | sed "/Default Sink: /s/^.*?: (.*)/\1/p")"
fi

clampl() {
    # clampl MIN VALUE
    # If VALUE is less than MIN return MIN
    # Else return VALUE
    if [ "$2" -lt "$1" ]; then
        echo "$1"
    else
        echo "$2"
    fi
}

clamph() {
    # clamph MAX VALUE
    # If VALUE is greater than MAX return MAX
    # Else return VALUE
    if [ "$2" -gt "$1" ]; then
        echo "$1"
    else
        echo "$2"
    fi
}

get_index() {
    # get_index TYPE NAME
    # TYPE: A value to be passed to "pactl list short TYPE". See "man pactl(1)" for more information.
    # NAME: Name of the module, sink, etc.
    pactl list short "$1" | sed "/^[[:digit:]]+[[:space:]]+$2\b/="
}

get_properties_by_index() {
    # RECOMMENDED: Use get_properties_by_name instead
    # get_properties_by_index INDEX
    # <stdin>: Output of "pactl list ..." without short
    # INDEX: Index of the device
    sed 's/^$/\x00/;p' | cut -d '' -z -f"$1"
}

get_properties_by_name() {
    # get_properties_by_name TYPE NAME
    # TYPE: See get_index
    # NAME: See get_index
    pactl list "$1" | get_properties_by_index "$(get_index "$1" "$2")"
}

get_property() {
    # get_property name
    # <stdin>: output of "get_properties_by_index"
    # name: name of the property to get
    sed "/^[[:space:]]$1/s/[[:space:]]$1: (.*)/\1/p"
}

find_property() {
    # find_property TYPE NAME VALUE
    # <stdout>: index of the owner of the found property

    pactl list "$1" | get_property "$2" | sed "/^$3\$/="
}

echo "SINK: $SINK" >&2

SINK_OWNER_MODULE="$(get_properties_by_name sinks "$SINK" | get_property "Owner Module")"
echo "SINK_OWNER_MODULE: $SINK_OWNER_MODULE" >&2
SINK_INPUT="$(find_property sink-inputs "Owner Module" "$SINK_OWNER_MODULE")"
echo "SINK_INPUT: $SINK_INPUT" >&2
if ! [ "$SINK_INPUT" ]; then
    echo "Could not find a sink-input for sink! Probably not a remap-sink." >&2
    exit 1
fi
SINK_INPUT_INDEX="$(pactl list sink-inputs | get_properties_by_index "$SINK_INPUT" | sed "s/^Sink Input #([[:digit:]]*)/\1/p")"
echo "SINK_INPUT_INDEX: $SINK_INPUT_INDEX" >&2
SINK_INPUT_VOLUME="$(pactl list sink-inputs | get_properties_by_index "$SINK_INPUT" | get_property "Volume" | sed "s/.*? ([[:digit:]]{0,3})%.*?/\1/p")"
echo "SINK_INPUT_VOLUME: $SINK_INPUT_VOLUME%" >&2

if [ "$BLOCK_BUTTON" = 4 ]; then
    SINK_INPUT_VOLUME="$(clamph $((SINK_INPUT_VOLUME + 5)) 100 100)"
    pactl set-sink-input-volume "$SINK_INPUT_INDEX" "$SINK_INPUT_VOLUME%"
elif [ "$BLOCK_BUTTON" = 5 ]; then
    SINK_INPUT_VOLUME="$(clampl 0 $((SINK_INPUT_VOLUME - 5)) 0)"
    pactl set-sink-input-volume "$SINK_INPUT_INDEX" "$SINK_INPUT_VOLUME%"
fi

printf "%s%%" "$SINK_INPUT_VOLUME"
exit 0
