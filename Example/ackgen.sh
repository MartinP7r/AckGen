# DIR=$PROJECT_TEMP_DIR/../../../SourcePackages/checkouts/AckGen
# Different path, because the sample uses AckGen as a local package:
DIR=..
if [ -d "$DIR" ]; then
    cd $DIR
    SDKROOT=(xcrun --sdk macosx --show-sdk-path)
    swift run ackgen --output "$SRCROOT/PackageLicenses.plist"
else
    echo "warning: AckGen not found. Please install the package via SPM (https://github.com/MartinP7r/AckGen#installation)"
fi
