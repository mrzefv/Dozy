#!/bin/bash
set -euo pipefail

SDK=$(xcrun --sdk iphoneos --show-sdk-path)
MIN_IOS=15.0
OUT_DIR="build"
OUT_NAME="MRvEKUplink.dylib"

mkdir -p "$OUT_DIR"

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
  src/MRvEKUplink.m \
  src/MRvEKConnectView.m \
  src/MRvEKBoardView.m \
  -o "$OUT_DIR/$OUT_NAME"

install_name_tool -id "@rpath/$OUT_NAME" "$OUT_DIR/$OUT_NAME"

echo "Built $OUT_DIR/$OUT_NAME"
