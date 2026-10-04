#!/usr/bin/env bash
set -euo pipefail
(cd dist && sha256sum -c release.tar.gz.sha256)
work=$(mktemp -d)
pid=''
cleanup() { if [[ -n "$pid" ]]; then kill "$pid" 2>/dev/null || true; wait "$pid" 2>/dev/null || true; fi; rm -rf "$work"; }
trap cleanup EXIT
tar -xzf dist/release.tar.gz -C "$work"
export RELEASE_ID="$(cat "$work/RELEASE_ID")"
export PORT=3187
node "$work/src/server.mjs" > "$work/server.log" 2>&1 &
pid=$!
for attempt in {1..30}; do
  if node --input-type=module -e 'const r=await fetch("http://127.0.0.1:"+process.env.PORT+"/version"); const b=await r.json(); if(r.status!==200 || b.release!==process.env.RELEASE_ID) process.exit(1)' 2>/dev/null; then exit 0; fi
  sleep 0.2
done
cat "$work/server.log"
exit 1
