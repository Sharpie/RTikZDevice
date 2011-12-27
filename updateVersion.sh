#!/bin/bash
if test -z "$1"; then
  head_sha=`git log --pretty='%h' -n1 master`
  vNum="`git describe r-forge| cut -d '-' -f 1,2`-$head_sha"
else
  vNum=$1
fi

printf "Updating version number to $vNum\n"

echo "$vNum" > inst/GIT_VERSION
