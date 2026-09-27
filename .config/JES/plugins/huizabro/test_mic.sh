#!/usr/bin/env bash
# Тестовый скрипт для OSD плагина типа "percent" (микрофон)
VOL=0
UP=true

while true; do
    echo "{\"value\": $VOL, \"sign\": \"󰍬\"}"
    
    if [ "$UP" = true ]; then
        VOL=$((VOL + 10))
        if [ $VOL -ge 100 ]; then
            UP=false
        fi
    else
        VOL=$((VOL - 10))
        if [ $VOL -le 0 ]; then
            UP=true
        fi
    fi
    
    sleep 3
done
