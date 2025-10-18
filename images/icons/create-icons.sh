for i in 64 128 192 264 256 432 512 1024; do
    inkscape icon.svg -o "icon${i}.png" -w $i
done

# ICO for Windows
convert icon64.png icon64.ico

# Android
convert -size 432x432 xc:none \( icon264.png -geometry +10+0 \) -gravity center -composite android-foreground-icon.png
convert ../background.png -gravity center -crop 432x432+0+0 +repage android-background-icon.png


