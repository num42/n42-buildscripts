#!/bin/sh
SCRIPT_FILE="UpdateVersion.sh"
SCRIPT_SOURCE="https://raw.githubusercontent.com/num42/n42-buildscripts/master/iOS/${SCRIPT_FILE}"

echo "Running N42 UpdateVersion Script v1.00 (2017-06-29)"

if [[ $1 == "-u" ]] ; then
  echo ""
  echo  "Updating ${SCRIPT_FILE}";
  curl -L $SCRIPT_SOURCE?$(date +%s) -o $0
  exit 1
fi

export PATH="/usr/local/opt/rbenv/shims:$PATH"
export PATH="${HOME}/.rbenv/shims:$PATH"

INFO_PLIST="${BUILT_PRODUCTS_DIR}/${WRAPPER_NAME}/Info"

# write the latest tag, without leading v
defaults write "$INFO_PLIST" CFBundleShortVersionString $(git describe --tags --abbrev=0  | sed s/v//g)

# Write the date (GMT)
defaults write "$INFO_PLIST" CFBundleVersion $(date -u "+%Y.%m.%d.%H.%M")

# Write the short commit hash
defaults write "$INFO_PLIST" GIT_COMMIT_HASH $(git rev-parse --short HEAD |  tr "[:lower:]" "[:upper:]")
