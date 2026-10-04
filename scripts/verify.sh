#!/usr/bin/env bash
# Vérification locale du périmètre pédagogique ; aucun accès distant.
set -euo pipefail
cd "$(dirname "$0")/.."
node --check src/server.mjs
bash -n scripts/*.sh
node scripts/security_check.mjs
npm test
bash scripts/build.sh
bash scripts/smoke.sh
backup=$(mktemp)
cp dist/release.tar.gz "$backup"
restore() { cp "$backup" dist/release.tar.gz; rm -f "$backup"; }
trap restore EXIT
printf 'corruption' >> dist/release.tar.gz
if bash scripts/smoke.sh; then
  echo 'Erreur : le paquet corrompu a été accepté.' >&2
  exit 1
fi
restore
trap - EXIT
echo 'Vérification réussie : tests, paquet servi et rejet de corruption.'
