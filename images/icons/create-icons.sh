for i in 64 128 192 264 256 432 512 1024; do
    inkscape icon.svg -o "icon${i}.png" -w $i
done

# ICO for Windows
convert icon64.png icon64.ico

# Android
convert -size 432x432 xc:none \( icon264.png -geometry +10+0 \) -gravity center -composite android-foreground-icon432.png
convert -size 512x512 xc:none \( icon432.png -geometry +10+0 \) -gravity center -composite android-foreground-icon512.png
convert ../background.png -gravity center -crop 432x432+0+0 +repage android-background-icon432.png
convert ../background.png -gravity center -crop 512x512+0+0 +repage android-background-icon512.png
convert android-background-icon512.png android-foreground-icon512.png -gravity center -composite android-composed512.png


