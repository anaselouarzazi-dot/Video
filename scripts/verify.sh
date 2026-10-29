#!/usr/bin/env bash
# End-to-end check: FFmpeg, HyperFrames render, Remotion render, FFmpeg post-processing.
set -euo pipefail
cd "$(dirname "$0")/.."
OUT=out/verify
rm -rf "$OUT" && mkdir -p "$OUT"
pass() { printf '  \033[32m✓\033[0m %s\n' "$1"; }
fail() { printf '  \033[31m✗\033[0m %s\n' "$1"; exit 1; }

probe() { # file -> "codec WxH duration"
  ffprobe -v error -select_streams v:0 \
    -show_entries stream=codec_name,width,height:format=duration \
    -of default=nw=1:nk=1 "$1" | paste -sd' '
}

echo "==> Tooling"
pass "node $(node -v)"
pass "$(ffmpeg -version | head -1 | cut -d' ' -f1-3)"
pass "hyperframes $(npx hyperframes --version)"
pass "remotion $(node -p 'require("remotion/package.json").version')"
encoders=$(ffmpeg -hide_banner -encoders)
for enc in libx264 libx265 libvpx-vp9 libsvtav1 aac libopus; do
  grep -q " $enc " <<<"$encoders" && pass "encoder $enc" || fail "encoder $enc missing"
done
filters=$(ffmpeg -hide_banner -filters)
for f in drawtext subtitles xfade loudnorm zscale; do
  grep -q " $f " <<<"$filters" && pass "filter $f" || fail "filter $f missing"
done

echo "==> HyperFrames"
(cd hyperframes && npx hyperframes lint . >/dev/null && npx hyperframes render --quiet -o "../$OUT/hyperframes.mp4" >/dev/null 2>&1)
pass "hyperframes.mp4: $(probe "$OUT/hyperframes.mp4")"

echo "==> Remotion"
npx tsc
npx remotion render Intro "$OUT/remotion.mp4" --log=error >/dev/null
pass "remotion.mp4: $(probe "$OUT/remotion.mp4")"
npx remotion still Intro "$OUT/remotion.png" --frame=45 --log=error >/dev/null
pass "remotion.png: $(probe "$OUT/remotion.png")"

echo "==> FFmpeg post-production"
ffmpeg -v error -f lavfi -i "sine=frequency=440:duration=10" -c:a aac "$OUT/tone.m4a"
bash scripts/ff.sh xfade "$OUT/hyperframes.mp4" "$OUT/remotion.mp4" "$OUT/joined.mp4" 1
pass "xfade join: $(probe "$OUT/joined.mp4")"
bash scripts/ff.sh audio "$OUT/joined.mp4" "$OUT/tone.m4a" "$OUT/final.mp4"
ffprobe -v error -select_streams a:0 -show_entries stream=codec_name -of csv=p=0 "$OUT/final.mp4" | grep -q aac
pass "audio mux: $(probe "$OUT/final.mp4") + aac"
bash scripts/ff.sh web "$OUT/final.mp4" "$OUT/final.webm"
pass "webm: $(probe "$OUT/final.webm")"
bash scripts/ff.sh gif "$OUT/remotion.mp4" "$OUT/preview.gif"
pass "gif: $(probe "$OUT/preview.gif")"

echo "==> All checks passed. Outputs in $OUT/"
