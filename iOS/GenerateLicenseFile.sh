#!/bin/sh
SCRIPT_FILE="GenerateLicenseFile.sh"
SCRIPT_SOURCE="https://raw.githubusercontent.com/num42/n42-buildscripts/master/iOS/${SCRIPT_FILE}"

echo "Running N42 License Script v1.00 (2017-06-29)"

if [[ $1 == "-u" ]] ; then
echo ""
echo  "Updating ${SCRIPT_FILE}";
curl -L $SCRIPT_SOURCE?$(date +%s) -o $0
exit 1
fi

SETTINGS_BUNDLE_PATH=$1

echo "Writing Licence file"
/usr/bin/python "${SRCROOT}/Carthage/Checkouts/LicenseGenerator-iOS/credits.py" -e "${SRCROOT}/Carthage/Checkouts/LicenseGenerator-iOS/Example" -s "${SRCROOT}/Carthage" -o "$SETTINGS_BUNDLE_PATH/Acknowledgements.plist"
