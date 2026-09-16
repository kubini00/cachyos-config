#!/bin/bash
#echo dej mi tapete
x=$1
case "$2" in 
    1) wal --backend wal -i $x -q -n --cols16 --saturate 0.35 -l;;
    *) wal --backend wal -i $x -q -n --cols16 --saturate 0.35
esac
# wal --backend colorz -i $x -q -n --saturate 0.5
awww img $x
#echo "brawo pedale ustawiles se $1"