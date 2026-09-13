echo "Maybe need to start LibreOffice manually?"

soffice --headless --accept="socket,host=localhost,port=2002;urp;"

echo "LibreOffice seems to be OK."

# convert odg files to pdf and then to svg.
# svg files are prepended by the page number.

echo "Convert odg to svg (via pdf))"
for img in "tracks.odg" "rails.odg" "flags.odg"; do
    base="${img%.*}"
    echo "Convert ${img} to PDF…"
    soffice --headless --convert-to pdf "${img}"
    echo "Convert ${base}.pdf to SVG…"
    pdf2svg "${base}.pdf" "${base}%d.svg" all    
    rm "${base}.pdf"
done

echo "Add transparency back and shrink…"

SEARCH="fill-opacity=\"1\""
REPLACE="fill-opacity=\"0\""

mkdir -p "png"
mkdir -p "svg"
for img in *.svg; do
  echo "  ${img}"
  base="${img%.*}"
  # first SEARCH gives the range, so only first occurence is replaced
  sed -i -e "0,/${SEARCH}/ s/${SEARCH}/${REPLACE}/" "${img}" 
  
  # convert to png (inkscape preserves transparency)
  inkscape "${img}" -o "png/${base}.png" -w 120
  mv "${img}" "svg/"
done


cd "png"
montage flags{1..2}.png -tile 1x2 -background 'transparent' -geometry +0+0 flags.png
cp "flags.png" "../../flags.png"
echo "png/flags.png has been created and copied to ../"


echo "Montage railsXXX.png…"
montage rails{1..6}.png -tile 6x1 -background 'transparent' -geometry +0+0 stations.png
montage rails{7..12}.png -tile 1x6 -background 'transparent' -geometry +0+0 trains1.png 
montage rails{13..18}.png -tile 1x6 -background 'transparent' -geometry +0+0 trains2.png 
montage rails{19..24}.png -tile 1x6 -background 'transparent' -geometry +0+0 trains3.png 
montage rails{25..30}.png -tile 1x6 -background 'transparent' -geometry +0+0 trains4.png 
montage rails{31..36}.png -tile 1x6 -background 'transparent' -geometry +0+0 trains5.png 
montage rails{37..42}.png -tile 1x6 -background 'transparent' -geometry +0+0 trains6.png 
montage trains{1..6}.png -tile 6x1 -background 'transparent' -geometry +0+0 trains.png 

montage stations.png trains.png -tile 1x2 -background 'transparent' -geometry +0+0 colored.png 

echo "Montage tracksXXX.png…"
montage tracks{1..6}.png -tile 6x1 -background 'transparent' -geometry +0+0 tracks.png

echo "Montage tracks, trains and stations…"
montage tracks.png colored.png -tile 1x2 -background 'transparent' -geometry +0+0 rails.png

cp "rails.png" "../../"

cp "../svg/rails11.svg" "../../icons/icon.svg"
echo "png/rails.png has been created and copied to ../rails.png."



echo "removing temporary png and svg files…"
cd ".."
rm -r "png"
rm -r "svg"

echo "Maybe want to run ../icons/create-icons.sh?"

