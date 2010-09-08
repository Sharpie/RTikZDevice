#!/bin/bash
if test -z "$1"; then
  vNum=`git describe master`
else
  vNum=$1
fi

printf "Updating version number to $vNum\n"

echo "$vNum" > inst/GIT_VERSION
