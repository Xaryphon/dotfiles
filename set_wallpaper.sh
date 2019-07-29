#!/bin/bash

if [[ $# -ne 0 ]]; then
    echo "$1" \> ~/.wallpaper
    cp "$1" ~/.wallpaper
    chmod 644 ~/.wallpaper
fi

mdim=$(xrandr | grep 'primary' | grep -oE "[[:digit:]]+x[[:digit:]]+")
magick ~/.wallpaper -resize "$mdim^" -gravity center -extent "$mdim" ~/.wallpaper_scaled
convert ~/.wallpaper_scaled -fill "#000000B3" -draw "rectangle 0,0,${mdim/x/,}" ~/.lockscreen
feh --bg-fill ~/.wallpaper_scaled
