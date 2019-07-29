#!/bin/sh

playerctl pause

unmute_output=0
if amixer get 'Master',0 | grep -q '\[on\]'; then
    unmute_output=1
    pactl set-sink-mute 0 1
fi

~/i3lock -n \
-i $HOME/.lockscreen -t \
--force-clock \
--timecolor="#ffffffff" \
--timestr="%H:%M:%S" \
--timepos="x+w/2:y+h/2-32" \
--timesize=40 \
--datecolor="#ffffffff" \
--datestr="Locked" \
--datepos="x+w/2:y+h/2" \
--datesize=20 \
--verifcolor="#ffffffff" \
--veriftext="..." \
--verifsize=32 \
--wrongcolor="#ffffffff" \
--wrongtext="•" \
--wrongsize=25 \
--noinputtext="" \
--insidevercolor="#00000000" \
--insidewrongcolor="#00000000" \
--insidecolor="#00000000" \
--ringvercolor="#00000000" \
--ringwrongcolor="#00000000" \
--ringcolor="#00000000" \
--linecolor="#00000000" \
--keyhlcolor="#00000000" \
--bshlcolor="#00000000" \
--separatorcolor="#00000000" \
--indpos="x+w/2:y+h/2+25"

if [ $unmute_output -eq 1 ]; then
    pactl set-sink-mute 0 0
fi
