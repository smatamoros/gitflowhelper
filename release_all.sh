#!/usr/bin/env bash

if ! [ $# -eq 3 ]; then
  echo "ERROR: number of parameters"
  echo "USAGE: release_all.sh [init | finish] <release_version> <projects_file>"
  exit 1
fi
while read p || [[ -n $p ]]; do
  ./release.sh $1 $2 $p
done <$3