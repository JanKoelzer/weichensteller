rm android*.import
#montage icon264.png -background none -geometry 264x264+0+0 -gravity center -extent 432x432 android-foreground-icon.png
convert icon264.png -background none -gravity center -extent 432x432 android-foreground-icon.png
convert ../background.png -gravity center -crop 432x432+0+0 +repage android-background-icon.png

