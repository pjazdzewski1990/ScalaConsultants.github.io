#!/bin/bash


if [ $# -lt 1 ]; then
  echo 1>&2 "$0: remember to add branch param"
  exit 2
elif [ $# -gt 1 ]; then
  echo 1>&2 "$0: too many arguments"
  exit 4
fi

date="$(date +'%d-%m-%Y-')"
echo "Starting blog work on $1 with $date"
git checkout -b "$1"
cp post-template.md _posts/$date$1.md