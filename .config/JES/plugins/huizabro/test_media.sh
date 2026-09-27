#!/usr/bin/env bash
# Тестовый скрипт для OSD плагина типа "text" (медиа/уведомления)
TRACKS=("Playing: Neru - Lost One's Weeping" "Paused: Hatsune Miku" "Playing: Kasane Teto - TETO" "Mute Enabled")
INDEX=0

while true; do
    TXT="${TRACKS[$INDEX]}"
    echo "{\"text\": \"$TXT\"}"
    
    INDEX=$(( (INDEX + 1) % ${#TRACKS[@]} ))
    sleep 5
done
