#!/bin/bash
set -euo pipefail

SDK=$(xcrun --sdk iphoneos --show-sdk-path)
MIN_IOS=15.0
OUT_DIR="build"
OUT_NAME="MRvEKUplink.dylib"
SRC_DIR="Mrzefv"

mkdir -p "$OUT_DIR"

shopt -s nullglob
SOURCES=("$SRC_DIR"/*.m)
if [ ${#SOURCES[@]} -eq 0 ]; then
  echo "No source files found in $SRC_DIR" >&2
  exit 1
fi

clang \
  -arch arm64 -arch arm64e \
  -isysroot "$SDK" \
  -miphoneos-version-min="$MIN_IOS" \
  -dynamiclib \
  -fobjc-arc \
  -fobjc-runtime=ios \
  -framework UIKit \
  -framework Foundation \
  -framework QuartzCore \
  "${SOURCES[@]}" \
  -o "$OUT_DIR/$OUT_NAME"

install_name_tool -id "@rpath/$OUT_NAME" "$OUT_DIR/$OUT_NAME"

echo "Built $OUT_DIR/$OUT_NAME from: ${SOURCES[*]}"
