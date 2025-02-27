#!/bin/bash

WW="WheelWizard"
# Change directory into WheelWizard and run build-mac.sh
cd /Users/gdmagana/Developer/WheelWizard/WheelWizard/
./build-mac.sh
cd ..

# Define source and destination directories
DEFAULT_DIR="/Users/gdmagana/Developer/WheelWizard/~macDirs/"
DIR="/Users/gdmagana/Developer/WheelWizard"

# Define target directories
TARGET_DIRS=("Universal" "osx-arm64" "osx-x64")
# Define source executables
EXE_DIR="/Users/gdmagana/Developer/WheelWizard/WheelWizard/WheelWizard/bin/Release/compiled"

# Loop through each target directory and copy the Contents folder
for TARGET in "${TARGET_DIRS[@]}"; do
    mkdir -p "$DIR/$TARGET"
    cp -R "$DEFAULT_DIR" "$DIR/$TARGET/WheelWizard.app/"
    mv "$EXE_DIR/$TARGET/WheelWizard" "$DIR/$TARGET/WheelWizard.app/Contents/MacOS"
    # Codesign all these app files
    APP_NAME="$DIR/$TARGET/WheelWizard.app"
    ENTITLEMENTS="$DIR/certs/WheelWizardEntitlements.entitlements"
    SIGNING_IDENTITY="Developer ID Application: Gabriel Magaña (Z4D7MUNZ97)"

    find "$APP_NAME/Contents/MacOS"|while read fname; do
        if [[ -f $fname ]]; then
            echo "[INFO] Signing $fname"
            codesign --force --timestamp --options=runtime --entitlements "$ENTITLEMENTS" --sign "$SIGNING_IDENTITY" "$fname"
        fi
    done

    echo "[INFO] Signing app file"

    codesign --force --timestamp --options=runtime --entitlements "$ENTITLEMENTS" --sign "$SIGNING_IDENTITY" "$APP_NAME"
    # Notarize this app file
    ditto -c -k --sequesterRsrc --keepParent "$DIR/$TARGET/WheelWizard.app" "$DIR/$TARGET/WheelWizard.zip"
    xcrun notarytool submit "$DIR/$TARGET/WheelWizard.zip"  --wait --keychain-profile WheelWizard
    # Staple this app file
    xcrun stapler staple "$DIR/$TARGET/WheelWizard.app"
    rm "$DIR/$TARGET/WheelWizard.zip"
    # Create a DMG File, named using readable names
    create-dmg \
    --icon-size 128 \
    --text-size 16 \
    --icon "WheelWizard.app" 200 150 \
    --app-drop-link 450 150 \
    --window-pos 200 200 \
    --window-size 650 376 \
    --background "$DIR/backgr.png" \
    --disk-image-size 150 \
    $DIR/$TARGET/WheelWizard-$TARGET.dmg $DIR/$TARGET

    # Notarize this DMG file
    xcrun notarytool submit "$DIR/$TARGET/WheelWizard-$TARGET.dmg"  --wait --keychain-profile WheelWizard
    # Staple this DMG file
    xcrun stapler staple "$DIR/$TARGET/WheelWizard-$TARGET.dmg"
    
    # Clean up
    #rm -rf "$DIR/$TARGET"
done
