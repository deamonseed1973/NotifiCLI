#!/bin/bash
set -e

APPS=("NotifiCLI" "NotifiPersistent")
BUILD_DIR="build"

# Clean
rm -rf "$BUILD_DIR"

for APP_NAME in "${APPS[@]}"; do
    echo "🔨 Building $APP_NAME..."
    APP_BUNDLE="${BUILD_DIR}/${APP_NAME}.app"
    CONTENTS_DIR="${APP_BUNDLE}/Contents"
    MACOS_DIR="${CONTENTS_DIR}/MacOS"
    
    mkdir -p "$MACOS_DIR"

    # Copy appropriate Info.plist
    if [ "$APP_NAME" == "NotifiPersistent" ]; then
        cp Info_Persistent.plist "${CONTENTS_DIR}/Info.plist"
    else
        cp Info.plist "${CONTENTS_DIR}/Info.plist"
    fi

    # Compile Swift (target macOS 11.0+)
    swiftc main.swift -o "${MACOS_DIR}/${APP_NAME}" -target arm64-apple-macosx11.0

    # Ad-hoc sign
    codesign --force --deep -s - "$APP_BUNDLE"
    echo "✅ Built ${APP_BUNDLE}"
done

echo "🎉 All builds complete."
echo "Usage (Normal):     open -n -a build/NotifiCLI.app ..."
echo "Usage (Persistent): open -n -a build/NotifiPersistent.app ..."
