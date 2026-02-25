#!/usr/bin/env bash
set -euo pipefail
ZIP_PATH="${1:-}"
if [[ -z "$ZIP_PATH" ]]; then
  echo "Usage: $0 /path/to/overleaf-source.zip"
  exit 1
fi

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

unzip -q "$ZIP_PATH" -d "$TMP_DIR"

# If zip contains a single top-level folder, use it; otherwise use root
shopt -s dotglob nullglob
entries=("$TMP_DIR"/*)
if [[ ${#entries[@]} -eq 1 && -d "${entries[0]}" ]]; then
  SRC_DIR="${entries[0]}"
else
  SRC_DIR="$TMP_DIR"
fi

# Copy all source files except build artifacts
rsync -a --delete \
  --exclude='.git/' \
  --exclude='*.aux' --exclude='*.log' --exclude='*.out' --exclude='*.fdb_latexmk' --exclude='*.fls' \
  "$SRC_DIR"/ "$REPO_DIR"/

echo "Imported Overleaf source into $REPO_DIR"
echo "Now run:"
echo "  cd $REPO_DIR"
echo "  git add -A"
echo "  git commit -m 'Import Overleaf source'"
