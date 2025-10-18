soffice --headless --accept="socket,host=localhost,port=2002;urp;"

echo "Convert ODG to PDF…"
soffice --headless --convert-to pdf tracks.odg
soffice --headless --convert-to pdf rails.odg

echo "Convert PDF to SVG…"
pdf2svg tracks.pdf tracks%d.svg all
pdf2svg rails.pdf rails%d.svg all
rm tracks.pdf
rm rails.pdf

echo "Add transparency back and shrink…"

SEARCH="fill-opacity=\"1\""
REPLACE="fill-opacity=\"0\""

mkdir -p "64x64"
mkdir -p "svg"
for img in *.svg; do
  echo "  ${img}"
  base="${img%.*}"
  # first SEARCH gives the range, so only first occurence is replaced
  sed -i -e "0,/${SEARCH}/ s/${SEARCH}/${REPLACE}/" "${img}" 
  
  # convert to png (inkscape preserve transparency)
  inkscape "${img}" -o "64x64/${base}.png" -w 64
  mv "${img}" "svg/"
done


cd "64x64"
echo "Montage railsXXX.png…"
montage rails[1-6].png -tile 6x1 -background 'transparent' -geometry +0+0 stations.png
montage rails7.png rails8.png rails9.png rails10.png -tile 1x4 -background 'transparent' -geometry +0+0 trains1.png 
montage rails11.png rails12.png rails13.png rails14.png -tile 1x4 -background 'transparent' -geometry +0+0 trains2.png 
montage rails15.png rails16.png rails17.png rails18.png -tile 1x4 -background 'transparent' -geometry +0+0 trains3.png 
montage rails19.png rails20.png rails21.png rails22.png -tile 1x4 -background 'transparent' -geometry +0+0 trains4.png 
montage rails23.png rails24.png rails25.png rails26.png -tile 1x4 -background 'transparent' -geometry +0+0 trains5.png 
montage rails27.png rails28.png rails29.png rails30.png -tile 1x4 -background 'transparent' -geometry +0+0 trains6.png 

montage trains[1-6].png -tile 6x1 -background 'transparent' -geometry +0+0 trains.png 

montage stations.png trains.png -tile 1x2 -background 'transparent' -geometry +0+0 colored.png 

echo "Montage tracksXXX.png…"
montage tracks1.png tracks3.png tracks2.png tracks4.png tracks5.png tracks6.png -tile 6x1 -background 'transparent' -geometry +0+0 tracks.png

echo "Montage everything…"
montage tracks.png colored.png -tile 1x2 -background 'transparent' -geometry +0+0 rails.png


xdg-open rails.png &

cp "rails.png" "../../"

echo "64x64/rails.png has been created and copied to ../rails.png."
