#!/usr/bin/env bash
# Installs everything needed to create, edit, animate and render videos:
# Node deps (HyperFrames, Remotion, React, GSAP), FFmpeg, Chrome Headless Shell
# and the HyperFrames agent skills. Safe to re-run.
set -euo pipefail
cd "$(dirname "$0")/.."

if ! command -v ffmpeg >/dev/null || ! command -v ffprobe >/dev/null; then
  echo "==> Installing FFmpeg"
  if command -v apt-get >/dev/null; then
    SUDO=""; [ "$(id -u)" -ne 0 ] && SUDO="sudo"
    $SUDO apt-get update -qq && $SUDO apt-get install -y -qq ffmpeg fonts-dejavu fontconfig
  elif command -v brew >/dev/null; then
    brew install ffmpeg
  else
    echo "Install FFmpeg manually: https://ffmpeg.org/download.html" >&2
    exit 1
  fi
fi

echo "==> Installing Node dependencies"
npm ci 2>/dev/null || npm install

echo "==> Vendoring GSAP into the HyperFrames project"
mkdir -p hyperframes/vendor
cp node_modules/gsap/dist/gsap.min.js hyperframes/vendor/gsap.min.js

echo "==> Installing Chrome Headless Shell"
npx hyperframes browser ensure
# Remotion falls back to the HyperFrames browser (see remotion.config.ts)
# when its own download host is unreachable.
npx remotion browser ensure || echo "   Remotion download unavailable; using the HyperFrames Chrome instead."

echo "==> Installing HyperFrames agent skills"
npx hyperframes skills update || echo "   Skills install failed (optional)."

echo "==> Done. Run: npm run verify"
