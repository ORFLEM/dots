#!/bin/sh
# tg-theme-pack.sh — упаковывает matugen colors + плоский фон в .tdesktop-theme (zip)
# Вызывается как post_hook matugen ПОСЛЕ генерации colors-файла.

set -e

SRC="$HOME/tg-theme/colors.tdesktop-theme"
OUT_DIR="$HOME/tg-theme"
OUT="$OUT_DIR/matugen.tdesktop-theme"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

# 1. hex фона из сгенерированной темы (windowBg: #413a39; -> 413a39)
BG="$(grep -m1 '^windowBg:' "$SRC" | sed 's/^windowBg:[[:space:]]*//; s/;[[:space:]]*$//; s/^#//')"
case "$BG" in
  [!0-9a-fA-F]*|*[!0-9a-fA-F]*|???????????????*) echo "tg-theme-pack: bad windowBg '$BG'" >&2; exit 1 ;;
esac

# 2. собираем zip: colors + сплошной фон ровно цвета windowBg
cp "$SRC" "$TMP/colors.tdesktop-theme"
ffmpeg -y -loglevel error -f lavfi -i "color=0x$BG:s=1920x1080" -frames:v 1 "$TMP/background.png"

mkdir -p "$OUT_DIR"
(cd "$TMP" && zip -q -X "$OUT" colors.tdesktop-theme background.png)

echo "tg-theme-pack: $OUT (bg=#$BG)"
