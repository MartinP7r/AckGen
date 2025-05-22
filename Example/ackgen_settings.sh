DIR=.. # "${BUILD_DIR%/Build/*}/SourcePackages/checkouts/AckGen"

if [ -d "$DIR" ]; then
    cd "$DIR"
    SDKROOT=$(xcrun --sdk macosx --show-sdk-path)
    SETTINGS_BUNDLE=$(find "$SRCROOT" -type d -name "Settings.bundle" -print -quit)

    if [ -d "$SETTINGS_BUNDLE" ]; then
        PLIST_PATH="$SETTINGS_BUNDLE/Acknowledgements.plist"
        PROJECT_NAME=$(basename "$SRCROOT")
        swift run ackgen "$PLIST_PATH" 1 "$PROJECT_NAME"
    else
        echo "warning: Settings.bundle not found in the project."
    fi
else
    echo "warning: AckGen not found. Please install the package via SPM (https://github.com/MartinP7r/AckGen#installation)"
fi
