#!/bin/bash

bar="▁▂▃▄▅▆▇█"
dict="s/;//g;"

i=0
while [ $i -lt ${#bar} ]; do
    dict="${dict}s/$i/${bar:$i:1}/g;"
    i=$((i+1))
done

config_file="/tmp/polybar_cava_config"

cat > "$config_file" << EOF
[general]
bars = 12

[output]
method = raw
raw_target = /dev/stdout
data_format = ascii
ascii_max_range = 7
EOF

while true; do
    if playerctl -l | grep -q chromium; then
        cava -p "$config_file" | while read -r line; do

            # sprawdz czy dalej istnieje player
            playerctl -l | grep -q chromium || pkill -P $$ cava

            echo "$line" | sed "$dict"
        done
    else
        echo ""
        sleep 1
    fi
done
