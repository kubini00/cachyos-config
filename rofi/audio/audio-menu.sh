
#!/usr/bin/env bash

set -uo pipefail

THEME="$HOME/.config/rofi/audio/style.rasi"

command -v pactl >/dev/null || exit 1
command -v rofi >/dev/null || exit 1
command -v jq >/dev/null || exit 1

CURRENT=$(pactl get-default-sink 2>/dev/null || true)

mapfile -t SINKS < <(
    pactl -f json list sinks |
        jq -r '.[] | [.name, (.description // .name)] | @tsv'
)

((${#SINKS[@]} > 0)) || exit 0

OPTIONS=()
NAMES=()

for SINK in "${SINKS[@]}"; do
    NAME="${SINK%%$'\t'*}"
    DESC="${SINK#*$'\t'}"

    NAMES+=("$NAME")

    # ASCII indicators avoid the earlier Unicode parsing error.
    if [[ "$NAME" == "$CURRENT" ]]; then
        OPTIONS+=("(*)  $DESC  [ACTIVE]")
    else
        OPTIONS+=("( )  $DESC")
    fi
done

CHOICE=$(
    printf '%s\n' "${OPTIONS[@]}" |
        rofi -dmenu \
            -i \
            -no-custom \
            -format i \
            -p "Audio" \
            -theme "$THEME"
) || exit 0

[[ "$CHOICE" =~ ^[0-9]+$ ]] || exit 0
((CHOICE < ${#NAMES[@]})) || exit 0

TARGET="${NAMES[$CHOICE]}"

pactl set-default-sink "$TARGET" || exit 1

while read -r INPUT_ID; do
    [[ -n "$INPUT_ID" ]] || continue
    pactl move-sink-input "$INPUT_ID" "$TARGET" 2>/dev/null || true
done < <(pactl list short sink-inputs | awk '{print $1}')
