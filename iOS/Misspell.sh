#!/bin/sh
SCRIPT_FILE="Misspell.sh"
SCRIPT_SOURCE="https://raw.githubusercontent.com/num42/n42-buildscripts/master/iOS/${SCRIPT_FILE}"

echo "Running N42 Misspell Script v1.00 (2017-05-05)"

if [[ $1 == "-u" ]] ; then
  echo ""
  echo  "$Updating ${SCRIPT_FILE}";
  curl -L $SCRIPT_SOURCE?$(date +%s) -o $0
  exit 1
fi

if which $HOME/go/bin/misspell >/dev/null; then
    $HOME/go//bin/misspell $* -o | sed 's/: \"/: warning: \"/g'
else
    echo “Misspell not installed, skipping.”
    exit 0
fi
