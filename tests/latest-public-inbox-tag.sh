#!/usr/bin/env bash
set -euo pipefail

root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
selector="$root/scripts/latest-public-inbox-tag.sh"
planner="$root/scripts/plan-public-inbox-build.sh"
workflow="$root/.github/workflows/docker-publish.yml"
tmp=$(mktemp -d)
trap 'rm -rf -- "$tmp"' EXIT HUP INT TERM
state="$tmp/state"
release_sha=1111111111111111111111111111111111111111
old_head=2222222222222222222222222222222222222222
new_head=3333333333333333333333333333333333333333
has() { grep -Fqx -- "$1" <<< "$2" || { echo "missing plan value: $1" >&2; exit 1; }; }

selected=$(printf '%s\n' \
  'refs  refs/tags/v1.9.0' \
  'refs  refs/tags/v2.9.0' \
  'refs  refs/tags/v2.10.0' \
  'refs  refs/tags/v3.0.0-rc1' \
  'refs  refs/tags/v99.0.0-rc1' | "$selector")
[ "$selected" = v2.10.0 ]
if printf '' | "$selector" >/dev/null 2>&1; then exit 1; fi

# Missing state bootstraps the latest stable release.
plan=$("$planner" schedule "$state" v2.10.0 "$release_sha" "$old_head")
has mode=release "$plan"
has source_sha=$release_sha "$plan"
has image_version=2.10.0 "$plan"
has publish_version_tag=true "$plan"
has next_head=$old_head "$plan"
[[ ! -e $state ]]

# A new tag wins over changed HEAD on schedule and push, even if it aliases the release commit.
printf 'v2.9.0 %s\n' "$old_head" > "$state"
plan=$("$planner" schedule "$state" v2.10.0 "$release_sha" "$new_head")
has mode=release "$plan"
has source_sha=$release_sha "$plan"
has next_tag=v2.10.0 "$plan"
has next_head=$new_head "$plan"
plan=$("$planner" push "$state" v2.10.0 "$release_sha" "$new_head")
has mode=release "$plan"
has image_version=2.10.0 "$plan"
has publish_version_tag=true "$plan"
has next_tag=v2.10.0 "$plan"
has next_head=$old_head "$plan"
[[ $(<"$state") == "v2.9.0 $old_head" ]]

# Without a new release, changed upstream HEAD publishes only latest.
printf 'v2.10.0 %s\n' "$old_head" > "$state"
plan=$("$planner" schedule "$state" v2.10.0 "$release_sha" "$new_head")
has mode=head "$plan"
has source_sha=$new_head "$plan"
has image_version=rolling "$plan"
has publish_version_tag=false "$plan"
has next_tag=v2.10.0 "$plan"
has next_head=$new_head "$plan"
plan=$("$planner" workflow_dispatch "$state" v2.10.0 "$release_sha" "$new_head")
has mode=head "$plan"

# An already-published release makes push build upstream HEAD as latest only, preserving the weekly baseline.
printf 'v2.10.0 %s\n' "$old_head" > "$state"
plan=$("$planner" push "$state" v2.10.0 "$release_sha" "$new_head")
has mode=head "$plan"
has source_sha=$new_head "$plan"
has image_version=rolling "$plan"
has publish_version_tag=false "$plan"
has next_tag=v2.10.0 "$plan"
has next_head=$old_head "$plan"

# Push rebuilds HEAD even if it equals the saved weekly baseline; schedule skips unchanged HEAD.
plan=$("$planner" push "$state" v2.10.0 "$release_sha" "$old_head")
has mode=head "$plan"
has source_sha=$old_head "$plan"
has publish_version_tag=false "$plan"
has next_head=$old_head "$plan"
printf 'v2.10.0 %s\n' "$new_head" > "$state"
plan=$("$planner" schedule "$state" v2.10.0 "$release_sha" "$new_head")
has mode=skip "$plan"

release_build=$(make -s -n USER_ID=1000 PBI_VERSION="$release_sha" PBI_SOURCE=checkout IMAGE_VERSION=2.10.0 DOCKER_BUILD_ARGS=--no-cache)
grep -Fq 'docker build --no-cache -t public-inbox:2.10.0' <<< "$release_build"
grep -Fq -- '--build-arg PBI_SOURCE=checkout' <<< "$release_build"
head_build=$(make -s -n USER_ID=1000 PBI_VERSION="$new_head" PBI_SOURCE=checkout IMAGE_VERSION=rolling PUBLISH_VERSION_TAG=false DOCKER_BUILD_ARGS=--no-cache)
grep -Fq 'docker build --no-cache -t public-inbox:rolling' <<< "$head_build"
release_deploy=$(make -s -n deploy REPO=ghcr.io/example/ IMAGE_VERSION=2.10.0 PUBLISH_VERSION_TAG=true)
grep -Fq 'docker push ghcr.io/example/public-inbox:2.10.0' <<< "$release_deploy"
head_deploy=$(make -s -n deploy REPO=ghcr.io/example/ IMAGE_VERSION=rolling PUBLISH_VERSION_TAG=false)
! grep -Fq 'docker push ghcr.io/example/public-inbox:rolling' <<< "$head_deploy"
grep -Fq 'docker push ghcr.io/example/public-inbox' <<< "$head_deploy"

grep -Fq "cron: '0 8 * * 0'" "$workflow"
grep -Fq 'git ls-remote --symref "$upstream_url" HEAD' "$workflow"
grep -Fq 'COPY public-inbox /tmp/public-inbox' "$root/Dockerfile"
[ "$(grep -Fc "if: steps.upstream.outputs.mode != 'skip'" "$workflow")" -eq 6 ]
[ "$(grep -Fc 'make deploy REPO=$REPO_BASE IMAGE_VERSION="$IMAGE_VERSION" PUBLISH_VERSION_TAG="$PUBLISH_VERSION_TAG"' "$workflow")" -eq 2 ]
last_deploy_line=$(grep -nF 'make deploy REPO=$REPO_BASE IMAGE_VERSION="$IMAGE_VERSION" PUBLISH_VERSION_TAG="$PUBLISH_VERSION_TAG"' "$workflow" | tail -n1 | cut -d: -f1)
state_write_line=$(grep -nF ' > "$STATE_FILE"' "$workflow" | cut -d: -f1)
[ "$state_write_line" -gt "$last_deploy_line" ] || { echo 'state must update after both publishes' >&2; exit 1; }

echo 'public-inbox release workflow checks passed'
