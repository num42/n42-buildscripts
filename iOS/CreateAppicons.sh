#!/bin/sh

SCRIPT_FILE="CreateAppicons.sh"
SCRIPT_SOURCE="https://raw.githubusercontent.com/num42/n42-buildscripts/master/iOS/${SCRIPT_FILE}"

echo "Running AppiconScript v1.00 (2017-06-30)"

if [[ $1 == "-u" ]] ; then
    echo ""
    echo  "Updating ${SCRIPT_FILE}";
    curl -L $SCRIPT_SOURCE?$(date +%s) -o $0
    exit 1
fi


APPICON_SET_PATH=$1
APPICON_SOURCE_PATH=$2

if echo $OTHER_SWIFT_FLAGS | grep DEBUG_MODULES; then
    if [ ! -d "${PROJECT_DIR}/build" ]; then
        mkdir ${PROJECT_DIR}/build
    fi

    bg_size=`identify -format '%wx%h' "${APPICON_SOURCE_PATH}"`
    convert -size $bg_size -composite "${APPICON_SOURCE_PATH}" "${PROJECT_DIR}/BuildPhaseAssets/Debug.png"  -geometry $bg_size+0+0 -depth 8 "${PROJECT_DIR}/build/Appicon-Debug.png"

    IMAGE_NAME="${PROJECT_DIR}/build/Appicon-Debug.png"
else
    IMAGE_NAME="${APPICON_SOURCE_PATH}"
fi

BASE=`basename "$IMAGE_NAME"`

for SIZE in 20 29 40 48 50 55 57 58 60 72 76 80 87 100 114 120 144 152 167 172 180 196; do
    convert "$IMAGE_NAME" -resize $SIZEx$SIZE "$APPICON_SET_PATH/$SIZE.png" &
done;

wait
