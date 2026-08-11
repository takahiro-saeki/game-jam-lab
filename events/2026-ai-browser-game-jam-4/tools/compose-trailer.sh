#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 3 ]]; then
  echo "usage: FFMPEG_BIN=/path/to/ffmpeg $0 <silent.avi> <music.mp3> <output.mp4>" >&2
  exit 64
fi

ffmpeg_bin="${FFMPEG_BIN:-ffmpeg}"
video_source="$1"
music_source="$2"
output_path="$3"

if [[ -e "$output_path" ]]; then
  echo "Refusing to overwrite existing trailer: $output_path" >&2
  exit 73
fi

"$ffmpeg_bin" \
  -hide_banner \
  -i "$video_source" \
  -i "$music_source" \
  -filter_complex \
    "[0:v]scale=1920:1080:flags=lanczos,setsar=1[v];[1:a]volume=0.63,afade=t=out:st=59.2:d=0.8[a]" \
  -map "[v]" \
  -map "[a]" \
  -t 60 \
  -r 30 \
  -c:v libx264 \
  -preset slow \
  -crf 18 \
  -pix_fmt yuv420p \
  -c:a aac \
  -b:a 192k \
  -movflags +faststart \
  "$output_path"

echo "Created gameplay-first trailer: $output_path"
