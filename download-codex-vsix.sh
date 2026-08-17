#!/usr/bin/env bash
set -euo pipefail

# Download the Linux x64 VSIX for the official OpenAI Codex VS Code extension.
# Override these with environment variables if the Marketplace publishes a new build.
VERSION="${CODEX_VERSION:-26.5810.52044}"
TOTAL_BYTES="${CODEX_TOTAL_BYTES:-367299134}"
CHUNK_BYTES="${CODEX_CHUNK_BYTES:-8388608}"
PARALLEL="${CODEX_PARALLEL:-12}"
OUTPUT="${1:-$PWD/openai.chatgpt-${VERSION}-linux-x64.vsix}"
URL="${CODEX_VSIX_URL:-https://openai.gallerycdn.vsassets.io/extensions/openai/chatgpt/26.5810.52044/1786771347788/Microsoft.VisualStudio.Services.VSIXPackage?targetPlatform=linux-x64}"

if [[ -e "$OUTPUT" ]]; then
  echo "Refusing to overwrite existing file: $OUTPUT" >&2
  exit 2
fi

command -v curl >/dev/null || { echo "curl is required" >&2; exit 1; }
command -v xargs >/dev/null || { echo "xargs is required" >&2; exit 1; }
command -v unzip >/dev/null || { echo "unzip is required" >&2; exit 1; }

part_dir="$(mktemp -d "${TMPDIR:-/tmp}/codex-vsix-parts.XXXXXX")"
cleanup() {
  rm -rf -- "$part_dir"
}
trap cleanup EXIT INT TERM

last_chunk=$(( (TOTAL_BYTES + CHUNK_BYTES - 1) / CHUNK_BYTES - 1 ))
output_dir="$(dirname -- "$OUTPUT")"
mkdir -p "$output_dir"

download_chunk() {
  local index="$1"
  local start=$((index * CHUNK_BYTES))
  local end=$((start + CHUNK_BYTES - 1))
  local expected
  local actual
  local attempt
  local part="$part_dir/part-$index"

  if (( end >= TOTAL_BYTES )); then
    end=$((TOTAL_BYTES - 1))
  fi
  expected=$((end - start + 1))

  for attempt in 1 2 3 4 5; do
    curl -fsSL --retry 2 --connect-timeout 15 --max-time 600 \
      -H "Range: bytes=$start-$end" \
      -o "$part" "$URL" >/dev/null 2>&1 || true

    actual="$(wc -c < "$part" 2>/dev/null || printf '0')"
    if [[ "$actual" -eq "$expected" ]]; then
      printf 'chunk %02d/%02d complete (%s bytes)\n' "$((index + 1))" "$((last_chunk + 1))" "$actual"
      return 0
    fi
    sleep "$attempt"
  done

  echo "Failed chunk $index: expected $expected bytes, got ${actual:-0}" >&2
  return 1
}

export URL TOTAL_BYTES CHUNK_BYTES PARALLEL last_chunk part_dir
export -f download_chunk

echo "Downloading Codex ${VERSION} for Linux x64"
echo "Output: $OUTPUT"
echo "Parallel workers: $PARALLEL"

seq 0 "$last_chunk" |
  xargs -P "$PARALLEL" -I{} bash -c 'download_chunk "$1"' _ {}

for index in $(seq 0 "$last_chunk"); do
  part="$part_dir/part-$index"
  [[ -s "$part" ]] || { echo "Missing chunk: $index" >&2; exit 1; }
done

for index in $(seq 0 "$last_chunk"); do
  cat "$part_dir/part-$index"
done > "$OUTPUT"

echo
file "$OUTPUT"
sha256sum "$OUTPUT"
unzip -t "$OUTPUT" | tail -n 4
echo
echo "Download complete. Install with:"
echo "  code --install-extension \"$OUTPUT\""
