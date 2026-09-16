#!/usr/bin/env bash

walldir="${HOME}/Obrazy/wp/"
cacheDir="${HOME}/.cache/jp"


rofi_command="rofi -dmenu \
-theme ${HOME}/.config/rofi/wallpaper/style.rasi"

mkdir -p "${cacheDir}"

for imagen in "$walldir"/*.{jpg,jpeg,png,webp}; do
    [ -f "$imagen" ] || continue

    nombre_archivo=$(basename "$imagen")

    if [ ! -f "${cacheDir}/${nombre_archivo}" ]; then
convert -strip "$imagen" \
    -resize 640x360 \
    -background none \
    -gravity center \
    -extent 640x360 \
    "${cacheDir}/${nombre_archivo}"
    fi
done

wall_selection=$(
find "${walldir}" -maxdepth 1 -type f \
\( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) \
-exec basename {} \; | sort | while read -r A; do
    echo -en "$A\x00icon\x1f${cacheDir}/$A\n"
done | $rofi_command
)

[[ -n "$wall_selection" ]] || exit 1

x="${walldir}/${wall_selection}"
wal --backend wal -i $x -q -n --cols16 --saturate 0.35
awww img $x
mmsg dispatch reload_config
swaync-client -rs

exit 0
