#!/bin/sh

SCRIPT_FILE="CreateAppicons.sh"
SCRIPT_SOURCE="https://raw.githubusercontent.com/num42/n42-buildscripts/master/iOS/${SCRIPT_FILE}"

echo "Running AppiconScript v1.2.1 (20. February 2018)"

if [[ $1 == "-u" ]] ; then
    echo ""
    echo  "Updating ${SCRIPT_FILE}";
    curl -L $SCRIPT_SOURCE?$(date +%s) -o $0
    exit 1
fi


APPICON_SET_PATH=$1
APPICON_SOURCE_PATH=$2
DEBUG_LAYER_SOURCE_PATH=$3
APPICON_PATH="${APPICON_SOURCE_PATH}/Appicon.png"
DEBUG_LAYER_PATH="${DEBUG_LAYER_SOURCE_PATH}/Debug.png"

BASE=`basename "$IMAGE_NAME"`

if [ ! -d "${PROJECT_DIR}/build" ]; then
  mkdir ${PROJECT_DIR}/build
fi

case "$SWIFT_ACTIVE_COMPILATION_CONDITIONS" in
    *DEBUG_MODULES*)

        IMAGE_NAME_PATH="${APPICON_SOURCE_PATH}/Generated/"

        mkdir -p $IMAGE_NAME_PATH

        IMAGE_NAME="${IMAGE_NAME_PATH}/Appicon-Debug.png"

        bg_size=`identify -format '%wx%h' "${APPICON_PATH}"`
        convert -size $bg_size -composite "${APPICON_PATH}" "${DEBUG_LAYER_PATH}" -geometry $bg_size+0+0 -depth 8 "${IMAGE_NAME}";;

    *)
        IMAGE_NAME="${APPICON_PATH}";;
esac

TMP_PATH=${PROJECT_DIR}/build

OUTPUT_PATH=$APPICON_SET_PATH
BASE=`basename "$IMAGE_NAME"`

move_if_different(){

  if [ -e "$2" ]
  then
    #Compare the files at the paths given, count different bytes
    if [ $(cmp -l "$1" "$2" | wc -l) -lt 30 ]
    then
      # If files are equal, delete first file
      echo "not copying $1 as no changes are detected"
      rm "$1" &
    else
      # If files are different, update second file
      echo "copying $1 to $2"
      mv "$1" "$2"
    fi
  else
    # second file does not yet exist
    mv "$1" "$2"
  fi
}

convert "$IMAGE_NAME" -alpha off -write mpr:main +delete \
  mpr:main -resize "1024x1024" -write "$TMP_PATH/tmp_1024.png" +delete \
  mpr:main -resize "196x196" -write "$TMP_PATH/tmp_196.png" +delete \
  mpr:main -resize "180x180" -write "$TMP_PATH/tmp_180.png" +delete \
  mpr:main -resize "172x172" -write "$TMP_PATH/tmp_172.png" +delete \
  mpr:main -resize "167x167" -write "$TMP_PATH/tmp_167.png" +delete \
  mpr:main -resize "152x152" -write "$TMP_PATH/tmp_152.png" +delete \
  mpr:main -resize "144x144" -write "$TMP_PATH/tmp_144.png" +delete \
  mpr:main -resize "120x120" -write "$TMP_PATH/tmp_120.png" +delete \
  mpr:main -resize "114x114" -write "$TMP_PATH/tmp_114.png" +delete \
  mpr:main -resize "100x100" -write "$TMP_PATH/tmp_100.png" +delete \
  mpr:main -resize "87x87" "$TMP_PATH/tmp_87.png" &

# partly parrallelize for speed
convert "$IMAGE_NAME" -alpha off -write mpr:main +delete \
  mpr:main -resize "80x80" -write "$TMP_PATH/tmp_80.png" +delete \
  mpr:main -resize "76x76" -write "$TMP_PATH/tmp_76.png" +delete \
  mpr:main -resize "72x72" -write "$TMP_PATH/tmp_72.png" +delete \
  mpr:main -resize "60x60" -write "$TMP_PATH/tmp_60.png" +delete \
  mpr:main -resize "58x58" -write "$TMP_PATH/tmp_58.png" +delete \
  mpr:main -resize "57x57" -write "$TMP_PATH/tmp_57.png" +delete \
  mpr:main -resize "55x55" -write "$TMP_PATH/tmp_55.png" +delete \
  mpr:main -resize "50x50" -write "$TMP_PATH/tmp_50.png" +delete \
  mpr:main -resize "48x48" -write "$TMP_PATH/tmp_48.png" +delete \
  mpr:main -resize "40x40" -write "$TMP_PATH/tmp_40.png" +delete \
  mpr:main -resize "29x29" -write "$TMP_PATH/tmp_29.png" +delete \
  mpr:main -resize "20x20" "$TMP_PATH/tmp_20.png" &


wait

# only copy if different, to avoid asset recompile
for SIZE in 1024 196 180 172 167 152 144 120 114 100 87 80 76 72 60 58 57 55 50 48 40 29 20; do
  move_if_different "$TMP_PATH/tmp_$SIZE.png" "$OUTPUT_PATH/$SIZE.png" &
done;

wait
