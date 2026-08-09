#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
event_root="$(cd "$script_dir/.." && pwd)"
godot_root="$event_root/godot"
output_dir="$event_root/build/itch/project-charge"
archive_path="$event_root/build/itch/project-charge-web.zip"

mkdir -p "$output_dir"
find "$output_dir" -mindepth 1 -maxdepth 1 -type f -delete

godot --headless --path "$godot_root" \
  --export-release "Itch Project Charge" "$output_dir/index.html"

(
  cd "$output_dir"
  /usr/bin/zip -q -9 -r -FS "$archive_path" . \
    -x "*.DS_Store" "__MACOSX/*"
)

for required_file in index.html index.js index.pck index.wasm; do
  if [[ ! -f "$output_dir/$required_file" ]]; then
    echo "Missing required itch.io file: $required_file" >&2
    exit 1
  fi
done

if ! /usr/bin/unzip -Z1 "$archive_path" | /usr/bin/grep -x "index.html" >/dev/null; then
  echo "The itch.io ZIP does not contain index.html at its root" >&2
  exit 1
fi

echo "PROJECT CHARGE itch.io build: $output_dir"
echo "PROJECT CHARGE itch.io ZIP:   $archive_path"
