#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 5 ]]; then
  echo "usage: $0 EVENT STATE_FILE RELEASE_TAG RELEASE_SHA UPSTREAM_HEAD_SHA" >&2
  exit 2
fi
event=$1
state_file=$2
release_tag=$3
release_sha=$4
upstream_head=$5

case "$event" in
  push|schedule|workflow_dispatch) ;;
  *) echo "unsupported event: $event" >&2; exit 2 ;;
esac
[[ $release_tag =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]] || { echo "invalid stable tag: $release_tag" >&2; exit 1; }
sha_re='^([[:xdigit:]]{40}|[[:xdigit:]]{64})$'
[[ $release_sha =~ $sha_re && $upstream_head =~ $sha_re ]] || { echo 'invalid upstream commit SHA' >&2; exit 1; }

previous_tag=
previous_head=
has_state=false
if [[ -e $state_file ]]; then
  [[ -f $state_file ]] || { echo "invalid state file: $state_file" >&2; exit 1; }
  extra=
  IFS=' ' read -r previous_tag previous_head extra < "$state_file" || { echo "empty state file: $state_file" >&2; exit 1; }
  [[ -z $extra && $previous_tag =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ && $previous_head =~ $sha_re ]] || { echo "invalid state file: $state_file" >&2; exit 1; }
  has_state=true
fi

mode=skip
source_sha=
image_version=rolling
publish_version_tag=false
next_tag=$previous_tag
next_head=$previous_head
if [[ $event == push || $has_state == false || $release_tag != "$previous_tag" ]]; then
  mode=release
  source_sha=$release_sha
  image_version=${release_tag#v}
  publish_version_tag=true
  next_tag=$release_tag
  if [[ $event != push || $has_state == false ]]; then
    next_head=$upstream_head
  fi
elif [[ $upstream_head != "$previous_head" ]]; then
  mode=head
  source_sha=$upstream_head
  next_head=$upstream_head
fi

printf 'mode=%s\nsource_sha=%s\nimage_version=%s\npublish_version_tag=%s\nnext_tag=%s\nnext_head=%s\n' \
  "$mode" "$source_sha" "$image_version" "$publish_version_tag" "$next_tag" "$next_head"
