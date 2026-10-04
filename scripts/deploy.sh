#!/usr/bin/env bash
set -euo pipefail
# Variables fichier GitLab ; jamais de clé privée en clair dans Git.
: "${DEPLOY_HOST:?}" "${DEPLOY_USER:?}" "${SSH_PRIVATE_KEY:?}" "${SSH_KNOWN_HOSTS:?}"
[[ "$DEPLOY_HOST" =~ ^[a-zA-Z0-9.-]+$ && "$DEPLOY_USER" =~ ^[a-zA-Z0-9_-]+$ ]] || exit 2
[[ "${DEPLOY_PORT:-3000}" =~ ^[0-9]+$ ]] || exit 2
command -v ssh >/dev/null
command -v scp >/dev/null
(cd dist && sha256sum -c release.tar.gz.sha256)
key=$(mktemp); known=$(mktemp)
trap 'rm -f "$key" "$known"' EXIT
cp "$SSH_PRIVATE_KEY" "$key"; chmod 600 "$key"
cp "$SSH_KNOWN_HOSTS" "$known"
opts=(-i "$key" -o "UserKnownHostsFile=$known" -o StrictHostKeyChecking=yes -o BatchMode=yes)
target="$DEPLOY_USER@$DEPLOY_HOST"
incoming=$(ssh "${opts[@]}" "$target" 'mktemp -d /tmp/glossapro.XXXXXXXX')
[[ "$incoming" =~ ^/tmp/glossapro\.[a-zA-Z0-9]+$ ]] || exit 2
scp "${opts[@]}" dist/release.tar.gz dist/release.tar.gz.sha256 scripts/remote_release.sh "$target:$incoming/"
ssh "${opts[@]}" "$target" "bash '$incoming/remote_release.sh' '$incoming' '${DEPLOY_PORT:-3000}'"
