#!/usr/bin/env bash
# Common FFmpeg post-production recipes.
#   ff.sh xfade   A.mp4 B.mp4 OUT.mp4 [fade_seconds]   cross-fade two clips (same size/fps)
#   ff.sh concat  OUT.mp4 IN1.mp4 IN2.mp4 ...           join clips without re-encoding
#   ff.sh audio   VIDEO.mp4 AUDIO OUT.mp4               add/replace soundtrack (loudness-normalized)
#   ff.sh subs    VIDEO.mp4 SUBS.srt OUT.mp4            burn subtitles
#   ff.sh web     IN.mp4 OUT.webm                       VP9/Opus for the web
#   ff.sh gif     IN.mp4 OUT.gif [width]                high-quality palette GIF
#   ff.sh thumb   IN.mp4 OUT.png [seconds]              extract a frame
#   ff.sh social  IN.mp4 OUT.mp4                        H.264 high profile, faststart
set -euo pipefail
cmd=${1:-}; shift || true
ff() { ffmpeg -v error -y "$@"; }

case "$cmd" in
  xfade)
    a=$1 b=$2 out=$3 d=${4:-1}
    len=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$a")
    off=$(awk -v l="$len" -v d="$d" 'BEGIN{print l-d}')
    ff -i "$a" -i "$b" -filter_complex \
      "[0:v]fps=30,settb=AVTB,format=yuv420p[a];[1:v]fps=30,settb=AVTB,format=yuv420p[b];[a][b]xfade=transition=fade:duration=$d:offset=$off,format=yuv420p[v]" \
      -map "[v]" -c:v libx264 -crf 18 -preset medium -movflags +faststart "$out" ;;
  concat)
    out=$1; shift
    list=$(mktemp); for f in "$@"; do echo "file '$(realpath "$f")'" >>"$list"; done
    ff -f concat -safe 0 -i "$list" -c copy -movflags +faststart "$out"; rm -f "$list" ;;
  audio)
    ff -i "$1" -i "$2" -map 0:v -map 1:a -c:v copy -af loudnorm=I=-14:TP=-1.5:LRA=11 \
      -c:a aac -b:a 192k -shortest -movflags +faststart "$3" ;;
  subs)
    ff -i "$1" -vf "subtitles=$2" -c:v libx264 -crf 18 -c:a copy -movflags +faststart "$3" ;;
  web)
    ff -i "$1" -c:v libvpx-vp9 -crf 32 -b:v 0 -row-mt 1 -c:a libopus -b:a 128k "$2" ;;
  gif)
    w=${3:-640}
    ff -i "$1" -vf "fps=15,scale=$w:-1:flags=lanczos,split[a][b];[a]palettegen[p];[b][p]paletteuse" "$2" ;;
  thumb)
    ff -ss "${3:-1}" -i "$1" -frames:v 1 "$2" ;;
  social)
    ff -i "$1" -c:v libx264 -profile:v high -pix_fmt yuv420p -crf 18 -preset slow \
      -c:a aac -b:a 192k -movflags +faststart "$2" ;;
  *)
    sed -n '2,11p' "$0"; exit 1 ;;
esac
