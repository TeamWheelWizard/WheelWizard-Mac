#!/bin/bash
# From Avalonia Docs on macos deployment
TARGET_DIR=$1

APP_NAME="$TARGET_DIR/WheelWizard.app"
ENTITLEMENTS="certs/WheelWizardEntitlements.entitlements"
SIGNING_IDENTITY="Developer ID Application: Gabriel Magaña (Z4D7MUNZ97)"

find "$APP_NAME/Contents/MacOS"|while read fname; do
    if [[ -f $fname ]]; then
        echo "[INFO] Signing $fname"
        codesign --force --timestamp --options=runtime --entitlements "$ENTITLEMENTS" --sign "$SIGNING_IDENTITY" "$fname"
    fi
done

echo "[INFO] Signing app file"

codesign --force --timestamp --options=runtime --entitlements "$ENTITLEMENTS" --sign "$SIGNING_IDENTITY" "$APP_NAME"