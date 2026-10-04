#!/usr/bin/env bash
set -euo pipefail
incoming=$1; port=$2
[[ "$incoming" =~ ^/tmp/glossapro\.[a-zA-Z0-9]+$ && "$port" =~ ^[0-9]+$ ]] || exit 2
trap 'rm -rf "$incoming"' EXIT
cd "$incoming"
sha256sum -c release.tar.gz.sha256
base="$HOME/glossapro"
mkdir -p "$base/releases"
work=$(mktemp -d "$base/releases/prepare.XXXXXXXX")
tar -xzf release.tar.gz -C "$work"
release=$(cat "$work/RELEASE_ID")
[[ "$release" =~ ^[a-zA-Z0-9_-]+$ ]] || exit 2
# Identifiant unique par exécution ; le commit reste la version de l'application.
new="$base/releases/${release}.$(date +%s).$$"
mv "$work" "$new"
previous=$(readlink "$base/current" || true)
printf 'PORT=%s
RELEASE_ID=%s
' "$port" "$release" > "$new/service.env"
ln -s "$new" "$base/current.next"
mv -Tf "$base/current.next" "$base/current"
healthy() {
 for attempt in {1..30}; do
  if PORT="$port" RELEASE_ID="$release" node --input-type=module -e 'const r=await fetch("http://127.0.0.1:"+process.env.PORT+"/version"); const b=await r.json(); if(r.status!==200 || b.release!==process.env.RELEASE_ID) process.exit(1)' 2>/dev/null; then return 0; fi
  sleep 1
 done
 return 1
}
if systemctl --user restart glossapro.service && healthy; then
 printf 'Release %s déployée
' "$release"
else
 if [[ -n "$previous" ]]; then
  ln -s "$previous" "$base/current.rollback"
  mv -Tf "$base/current.rollback" "$base/current"
  systemctl --user restart glossapro.service
  echo 'Ancienne version réactivée ; vérifier sa santé.' >&2
 else
  systemctl --user stop glossapro.service || true
  echo 'Premier déploiement échoué ; intervention requise.' >&2
 fi
 exit 1
fi
