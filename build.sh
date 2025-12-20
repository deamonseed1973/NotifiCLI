#!/bin/bash
set -e

APP_NAME="NotifiCLI"
BUILD_DIR="build"
APP_BUNDLE="${BUILD_DIR}/${APP_NAME}.app"
CONTENTS_DIR="${APP_BUNDLE}/Contents"
MACOS_DIR="${CONTENTS_DIR}/MacOS"

# Clean
rm -rf "$BUILD_DIR"
mkdir -p "$MACOS_DIR"

# Copy Info.plist
cp Info.plist "${CONTENTS_DIR}/Info.plist"

# Compile Swift (target macOS 11.0+)
swiftc main.swift -o "${MACOS_DIR}/${APP_NAME}" -target arm64-apple-macosx11.0

# Ad-hoc sign
codesign --force --deep -s - "$APP_BUNDLE"

echo "✅ Built ${APP_BUNDLE}"
echo "Run source usage: ./${MACOS_DIR}/${APP_NAME} -title 'Test' -message 'Hello' -actions 'A,B'"
echo "Run app usage: open -n -a ${APP_BUNDLE} --args -title 'Test' -message 'Hello' -actions 'A,B'"
