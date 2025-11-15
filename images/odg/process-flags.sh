soffice --headless --accept="socket,host=localhost,port=2002;urp;"

echo "Convert ODG to PDF…"
soffice --headless --convert-to pdf flags.odg

echo "Convert PDF to SVG…"
pdf2svg flags.pdf flags%d.svg all
rm flags.pdf

echo "Add transparency back and shrink…"

SEARCH="fill-opacity=\"1\""
REPLACE="fill-opacity=\"0\""

mkdir -p "120x120"
mkdir -p "svg"
for img in *.svg; do
  echo "  ${img}"
  base="${img%.*}"
  # first SEARCH gives the range, so only first occurence is replaced
  sed -i -e "0,/${SEARCH}/ s/${SEARCH}/${REPLACE}/" "${img}" 
  
  # convert to png (inkscape preserve transparency)
  inkscape "${img}" -o "120x120/${base}.png" -w 120
  mv "${img}" "svg/"
done


cd "120x120"
echo "Montage flagsXXX.png…"
montage flags[1-4].png -tile 4x1 -background 'transparent' -geometry +0+0 flags.png

cp "flags1.png" "../../flag_de.png"
cp "flags2.png" "../../flag_en.png"

echo "removing temporary png and svg files…"
cd ".."
rm -r "120x120"
rm -r "svg"

