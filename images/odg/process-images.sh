#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# convert odg files to pdf and then to svg.
# svg files are prepended by the page number.

echo "Convert odg to svg (via pdf))"
for img_name in "tracks.odg" "trains_and_stations.odg" "flags.odg"; do
    img="$SCRIPT_DIR/$img_name"
    base="${img%.*}"
    echo "Convert ${img} to PDF…"
    soffice --headless --convert-to pdf --outdir "$SCRIPT_DIR" "$img"
    echo "Convert ${base}.pdf to SVG…"
    pdf2svg "${base}.pdf" "${base}%d.svg" all    
    rm "${base}.pdf"
done
# handle whistle separately, because there SVG code is different
for img_name in "whistle_on.odg" "whistle_off.odg"; do
    img="$SCRIPT_DIR/$img_name"
    base="${img%.*}"
    echo "Convert ${img} to SVG…"
    soffice --headless --convert-to svg --outdir "$SCRIPT_DIR" "$img"
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

echo "Montage $SCRIPT_DIR/png/trains_and_stationsXXX.png…"
montage "$SCRIPT_DIR/png/trains_and_stations"{1..6}.png -tile 6x1 -background 'transparent' -geometry +0+0 "$SCRIPT_DIR/png/stations.png"
montage "$SCRIPT_DIR/png/trains_and_stations"{7..15}.png -tile 1x9 -background 'transparent' -geometry +0+0 "$SCRIPT_DIR/png/trains1.png"
montage "$SCRIPT_DIR/png/trains_and_stations"{16..24}.png -tile 1x9 -background 'transparent' -geometry +0+0 "$SCRIPT_DIR/png/trains2.png"
montage "$SCRIPT_DIR/png/trains_and_stations"{25..33}.png -tile 1x9 -background 'transparent' -geometry +0+0 "$SCRIPT_DIR/png/trains3.png"
montage "$SCRIPT_DIR/png/trains_and_stations"{34..42}.png -tile 1x9 -background 'transparent' -geometry +0+0 "$SCRIPT_DIR/png/trains4.png"
montage "$SCRIPT_DIR/png/trains_and_stations"{43..51}.png -tile 1x9 -background 'transparent' -geometry +0+0 "$SCRIPT_DIR/png/trains5.png"
montage "$SCRIPT_DIR/png/trains_and_stations"{52..60}.png -tile 1x9 -background 'transparent' -geometry +0+0 "$SCRIPT_DIR/png/trains6.png"
montage "$SCRIPT_DIR/png/trains"{1..6}.png -tile 6x1 -background 'transparent' -geometry +0+0 "$SCRIPT_DIR/png/trains.png"

echo "Montage $SCRIPT_DIR/png/tracksXXX.png…"
montage "$SCRIPT_DIR/png/tracks"{1..6}.png -tile 6x1 -background 'transparent' -geometry +0+0 "$SCRIPT_DIR/png/tracks_pre.png"
montage "$SCRIPT_DIR/png/tracks_pre.png" "$SCRIPT_DIR/png/stations.png" -tile 1x2 -background 'transparent' -geometry +0+0 "$SCRIPT_DIR/png/tracks.png"

for img_name in "trains.png" "tracks.png" "whistle_on.png" "whistle_off.png" "flags.png"; do
    img="$SCRIPT_DIR/$img_name"
    cp "$SCRIPT_DIR/png/$img_name" "$SCRIPT_DIR/../$img_name"
    echo "$SCRIPT_DIR/png/$img_name.png has been created and copied to $SCRIPT_DIR/../$img_name." 
done

cp "$SCRIPT_DIR/svg/trains_and_stations13.svg" "$SCRIPT_DIR/../icons/icon.svg"
echo "$SCRIPT_DIR/svg/trains_and_stations13.svg has been created and copied to $SCRIPT_DIR/../icons/icon.svg."

echo "removing temporary png and svg files…"
rm -r "$SCRIPT_DIR/png"
rm -r "$SCRIPT_DIR/svg"

echo "Maybe want to run $SCRIPT_DIR/../icons/create-icons.sh?"

