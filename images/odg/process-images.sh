#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Maybe need to start LibreOffice manually?"

soffice --headless --accept="socket,host=localhost,port=2002;urp;"

echo "LibreOffice seems to be OK."

# convert odg files to pdf and then to svg.
# svg files are prepended by the page number.

echo "Convert odg to svg (via pdf))"
for img_name in "tracks.odg" "rails.odg" "flags.odg"; do
    img="$SCRIPT_DIR/$img_name"
    base="${img%.*}"
    echo "Convert ${img} to PDF…"
    soffice --headless --convert-to pdf --outdir "$SCRIPT_DIR" "$img"
    echo "Convert ${base}.pdf to SVG…"
    pdf2svg "${base}.pdf" "${base}%d.svg" all    
    rm "${base}.pdf"
done

echo "Add transparency back and shrink…"

SEARCH='fill-opacity="1"'
REPLACE='fill-opacity="0"'

mkdir -p "$SCRIPT_DIR/png"
mkdir -p "$SCRIPT_DIR/svg"
for img in "$SCRIPT_DIR"/*.svg; do
    echo "  ${img}"
    base="${img%.*}"
    filename="$(basename "$base")"
    # First SEARCH gives the range, so only first occurrence is replaced
    sed -i -e "0,/${SEARCH}/ s/${SEARCH}/${REPLACE}/" "$img" 
    # convert to png (inkscape preserves transparency)
    inkscape "$img" -o "$SCRIPT_DIR/png/${filename}.png" -w 120
    mv "$img" "$SCRIPT_DIR/svg/"
done

echo "Start with Montage"

montage "$SCRIPT_DIR/png/flags"{1..2}.png -tile 1x2 -background 'transparent' -geometry +0+0 "$SCRIPT_DIR/png/flags.png"
cp "$SCRIPT_DIR/png/flags.png" "$SCRIPT_DIR/../flags.png"
echo "$SCRIPT_DIR/png/flags.png has been created and copied to $SCRIPT_DIR/../"


echo "Montage $SCRIPT_DIR/png/railsXXX.png…"
montage "$SCRIPT_DIR/png/rails"{1..6}.png -tile 6x1 -background 'transparent' -geometry +0+0 "$SCRIPT_DIR/png/stations.png"
montage "$SCRIPT_DIR/png/rails"{7..12}.png -tile 1x6 -background 'transparent' -geometry +0+0 "$SCRIPT_DIR/png/trains1.png"
montage "$SCRIPT_DIR/png/rails"{13..18}.png -tile 1x6 -background 'transparent' -geometry +0+0 "$SCRIPT_DIR/png/trains2.png"
montage "$SCRIPT_DIR/png/rails"{19..24}.png -tile 1x6 -background 'transparent' -geometry +0+0 "$SCRIPT_DIR/png/trains3.png"
montage "$SCRIPT_DIR/png/rails"{25..30}.png -tile 1x6 -background 'transparent' -geometry +0+0 "$SCRIPT_DIR/png/trains4.png"
montage "$SCRIPT_DIR/png/rails"{31..36}.png -tile 1x6 -background 'transparent' -geometry +0+0 "$SCRIPT_DIR/png/trains5.png"
montage "$SCRIPT_DIR/png/rails"{37..42}.png -tile 1x6 -background 'transparent' -geometry +0+0 "$SCRIPT_DIR/png/trains6.png"
montage "$SCRIPT_DIR/png/trains"{1..6}.png -tile 6x1 -background 'transparent' -geometry +0+0 "$SCRIPT_DIR/png/trains.png"
montage "$SCRIPT_DIR/png/stations.png" "$SCRIPT_DIR/png/trains.png" -tile 1x2 -background 'transparent' -geometry +0+0 "$SCRIPT_DIR/png/colored.png"

echo "Montage $SCRIPT_DIR/png/tracksXXX.png…"
montage "$SCRIPT_DIR/png/tracks"{1..6}.png -tile 6x1 -background 'transparent' -geometry +0+0 "$SCRIPT_DIR/png/tracks.png"

echo "Montage tracks, trains and stations…"
montage "$SCRIPT_DIR/png/tracks.png" "$SCRIPT_DIR/png/colored.png" -tile 1x2 -background 'transparent' -geometry +0+0 "$SCRIPT_DIR/png/rails.png"

cp "$SCRIPT_DIR/png/rails.png" "$SCRIPT_DIR/../rails.png"
echo "$SCRIPT_DIR/png/rails.png has been created and copied to $SCRIPT_DIR/../rails.png."

cp "$SCRIPT_DIR/svg/rails11.svg" "$SCRIPT_DIR/../icons/icon.svg"
echo "$SCRIPT_DIR/svg/rails11.svg has been created and copied to $SCRIPT_DIR/../icons/icon.svg."


echo "removing temporary png and svg files…"
rm -r "$SCRIPT_DIR/png"
rm -r "$SCRIPT_DIR/svg"

echo "Maybe want to run $SCRIPT_DIR/../icons/create-icons.sh?"

