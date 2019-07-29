#!/bin/sh

echo "$2"
echo
if [ "$(systemctl is-active "$1")" = "active" ]; then
    echo \#00FF00
else
    echo \#FF0000
fi
