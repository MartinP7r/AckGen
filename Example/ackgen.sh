# For the Example app, AckGen is used as a local package, so we use a simple relative path
# In your own project with SPM, use the dynamic path calculation from the README:
# BASE_DIR=$(echo "$PROJECT_TEMP_DIR" | awk -F'/Build/' '{print $1}')
# DIR="$BASE_DIR/SourcePackages/checkouts/AckGen"
DIR=..

if [ -d "$DIR" ]; then
    cd "$DIR"
    SDKROOT=$(xcrun --sdk macosx --show-sdk-path)
    swift run ackgen "$SRCROOT/PackageLicenses.plist"
else
    echo "warning: AckGen not found. Please install the package via SPM (https://github.com/MartinP7r/AckGen#installation)"
fi

