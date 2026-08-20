#!/bin/bash
set -euo pipefail

SDK=$(xcrun --sdk iphoneos --show-sdk-path)
MIN_IOS=15.0
OUT_DIR="build"
OUT_NAME="MRvEKUplink.dylib"
SRC_DIR="Mrzefv"

mkdir -p "$OUT_DIR"

# Explicit file list on purpose — anything else sitting in Mrzefv/
# (old files not yet deleted) is ignored instead of silently pulled
# into the build.
SOURCES=(
  "$SRC_DIR/MRvEKUplink.m"
  "$SRC_DIR/MRvEKConnectView.m"
  "$SRC_DIR/MRvEKBoardView.m"
  "$SRC_DIR/MRvEKPostDetailView.m"
  "$SRC_DIR/MRvEKIdentity.m"
  "$SRC_DIR/MRvEKFileTransfer.m"
)

for f in "${SOURCES[@]}"; do
  if [ ! -f "$f" ]; then
    echo "Missing source file: $f" >&2
    exit 1
  fi
done

clang \
  -arch arm64 -arch arm64e \
  -isysroot "$SDK" \
  -miphoneos-version-min="$MIN_IOS" \
  -dynamiclib \
  -fobjc-arc \
  -framework UIKit \
  -framework Foundation \
  -framework QuartzCore \
  -framework CoreGraphics \
  -framework Security \
  -framework UniformTypeIdentifiers \
  "${SOURCES[@]}" \
  -o "$OUT_DIR/$OUT_NAME"

install_name_tool -id "@rpath/$OUT_NAME" "$OUT_DIR/$OUT_NAME"

echo "Built $OUT_DIR/$OUT_NAME"
