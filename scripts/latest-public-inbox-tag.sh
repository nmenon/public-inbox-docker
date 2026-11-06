#!/bin/sh
set -eu

latest=$(awk '
  index($2, "refs/tags/") == 1 {
    tag = substr($2, 11)
    if (tag ~ /^v[0-9]+[.][0-9]+[.][0-9]+$/) print tag
  }
' | sort -V | tail -n 1)

if [ -z "$latest" ]; then
  echo "No stable vMAJOR.MINOR.PATCH public-inbox release tag found" >&2
  exit 1
fi
printf '%s\n' "$latest"
