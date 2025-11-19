soffice --headless --accept="socket,host=localhost,port=2002;urp;"

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

cp "flags1.png" "../../flag_de.png"
cp "flags2.png" "../../flag_en.png"
echo "png/flagsXX.png have been created and copied to ../"


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
montage tracks[1-6].png -tile 6x1 -background 'transparent' -geometry +0+0 tracks.png

echo "Montage tracks, trains and stations…"
montage tracks.png colored.png -tile 1x2 -background 'transparent' -geometry +0+0 rails.png

cp "rails.png" "../../"
for i in 1 2 3 4 5 6; do cp "rails$i.png" "../../stations/station_$((i-1)).png" ; done

cp "../svg/rails10.svg" "../../icons/icon.svg"
echo "png/rails.png has been created and copied to ../rails.png."



echo "removing temporary png and svg files…"
cd ".."
rm -r "png"
rm -r "svg"

