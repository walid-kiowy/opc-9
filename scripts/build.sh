#!/usr/bin/env bash
set -euo pipefail
release=${CI_COMMIT_SHA:-${GITHUB_SHA:-local}}
[[ "$release" =~ ^[a-zA-Z0-9_-]+$ ]] || exit 2
mkdir -p dist
printf '%s
' "$release" > dist/RELEASE_ID
tar -czf dist/release.tar.gz src package.json -C dist RELEASE_ID
(cd dist && sha256sum release.tar.gz > release.tar.gz.sha256)
