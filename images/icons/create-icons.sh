for i in 16 32 48 64 128 192 256 264 432 512 1024; do
    inkscape icon.svg -o "icon${i}.png" -w $i
done

# ICO for Windows
convert icon16.png icon48.png icon32.png icon64.png icon128.png icon256.png -colors 256 icon-multisize.ico

# Android
convert -size 432x432 xc:none \( icon264.png -geometry +10+0 \) -gravity center -composite android-foreground-icon432.png
convert -size 512x512 xc:none \( icon432.png -geometry +10+0 \) -gravity center -composite android-foreground-icon512.png
convert ../background.png -gravity center -crop 432x432+0+0 +repage android-background-icon432.png
convert ../background.png -gravity center -crop 512x512+0+0 +repage android-background-icon512.png
convert android-background-icon512.png android-foreground-icon512.png -gravity center -composite android-composed512.png

for i in 16 32 48 64 128 256 264 512; do
    rm "icon${i}.png"
done

