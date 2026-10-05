#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

for i in 16 32 48 64 128 192 256 264 432 512 1024; do
    inkscape "$SCRIPT_DIR/icon.svg" -o "$SCRIPT_DIR/icon${i}.png" -w $i
done

# ICO for Windows
convert "$SCRIPT_DIR/icon16.png" "$SCRIPT_DIR/icon48.png" "$SCRIPT_DIR/icon32.png" "$SCRIPT_DIR/icon64.png" "$SCRIPT_DIR/icon128.png" "$SCRIPT_DIR/icon256.png" -colors 256 "$SCRIPT_DIR/icon-multisize.ico"

# Android
convert -size 432x432 xc:none \( "$SCRIPT_DIR/icon264.png" -geometry +10+0 \) -gravity center -composite "$SCRIPT_DIR/android-foreground-icon432.png"
convert -size 512x512 xc:none \( "$SCRIPT_DIR/icon432.png" -geometry +10+0 \) -gravity center -composite "$SCRIPT_DIR/android-foreground-icon512.png"

convert -size 512x512 canvas:#f0dbb9 "$SCRIPT_DIR/android-background-icon512.png"
convert -size 432x432 canvas:#f0dbb9 "$SCRIPT_DIR/android-background-icon432.png"

convert "$SCRIPT_DIR/android-background-icon512.png" "$SCRIPT_DIR/android-foreground-icon512.png" -gravity center -composite "$SCRIPT_DIR/android-composed512.png"

for i in 16 32 48 64 128 256 264 512; do
    rm "$SCRIPT_DIR/icon${i}.png"
done

