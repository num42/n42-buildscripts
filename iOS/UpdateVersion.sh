#!/bin/sh
SCRIPT_FILE="UpdateVersion.sh"
SCRIPT_SOURCE="https://raw.githubusercontent.com/num42/n42-buildscripts/master/iOS/${SCRIPT_FILE}"

echo "Running N42 UpdateVersion Script v1.1 (20. February 2018)"

if [[ $1 == "-u" ]] ; then
  echo ""
  echo  "Updating ${SCRIPT_FILE}";
  curl -L $SCRIPT_SOURCE?$(date +%s) -o $0
  exit 1
fi

export PATH="/usr/local/opt/rbenv/shims:$PATH"
export PATH="${HOME}/.rbenv/shims:$PATH"

INFO_PLIST="${BUILT_PRODUCTS_DIR}/${WRAPPER_NAME}/Info"

# if on a release branch
if [[ $(git branch | grep \* | cut -d ' ' -f2 | cut -d "/" -f1) == release ]] ;
then
  # use the branch name
  VERSION_TAG=$(git branch | grep \* | cut -d ' ' -f2 | cut -d "/" -f2)
# the branch is also a release branch (e.g. dev == releaseV1.0)
elif [[ $(git show-ref | grep $(git rev-parse HEAD) | grep release | rev | cut -d "/" -f 2 | rev) == release ]] ;
then
  # use the branch name
  VERSION_TAG=$(git show-ref | grep $(git rev-parse HEAD) | grep release | rev | cut -d "/" -f 1 | rev)
else
  # use the latest tag otherwise
  # do not take error messages: 2>/dev/null
  # use v0.0 if an error occurs: || echo "v0.0"
  VERSION_TAG=$(git describe --tags --abbrev=0  2>/dev/null || echo "v0.0")
fi

# write the latest tag, without leading v
defaults write "$INFO_PLIST" CFBundleShortVersionString $(echo $VERSION_TAG | sed s/v//g)

# Write the date (GMT)
defaults write "$INFO_PLIST" CFBundleVersion $(date -u "+%Y.%m.%d.%H.%M")

# Write the short commit hash
defaults write "$INFO_PLIST" GIT_COMMIT_HASH $(git rev-parse --short HEAD |  tr "[:lower:]" "[:upper:]")
