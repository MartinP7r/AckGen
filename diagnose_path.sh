#!/bin/bash
# Script to diagnose AckGen path detection issues
# Run this from your Xcode Run Script phase or manually with environment variables set

set -e

echo "🔍 AckGen Path Diagnostics"
echo "=========================="
echo ""

# Check if we're running in an Xcode environment
if [ -z "$PROJECT_TEMP_DIR" ]; then
    echo "❌ ERROR: PROJECT_TEMP_DIR is not set"
    echo "This script must be run from an Xcode Run Script phase or with PROJECT_TEMP_DIR set"
    echo ""
    echo "To test manually, set PROJECT_TEMP_DIR to your Xcode build directory, e.g.:"
    echo "export PROJECT_TEMP_DIR=/Users/\$USER/Library/Developer/Xcode/DerivedData/YourApp-xyz/Build/Intermediates.noindex/YourApp.build"
    exit 1
fi

echo "📂 Environment Variables:"
echo "  PROJECT_TEMP_DIR: $PROJECT_TEMP_DIR"
echo "  SRCROOT: ${SRCROOT:-not set}"
echo ""

# Calculate package path using the same logic as AckGen CLI
CALCULATED_BASE=$(echo "$PROJECT_TEMP_DIR" | awk -F'/Build/' '{print $1}')
CALCULATED_PACKAGE_PATH="${CALCULATED_BASE}/SourcePackages/checkouts"

echo "🧮 Path Calculation:"
echo "  Base directory: $CALCULATED_BASE"
echo "  Package path: $CALCULATED_PACKAGE_PATH"
echo ""

# Check using relative path approach (from README)
RELATIVE_BASE="$PROJECT_TEMP_DIR/../../../"
RELATIVE_PACKAGE_PATH="${RELATIVE_BASE}/SourcePackages/checkouts"

echo "📍 Relative Path Approach (from README):"
echo "  Relative base: $RELATIVE_BASE"
echo "  Package path: $RELATIVE_PACKAGE_PATH"
echo ""

# Verify both approaches
echo "✅ Verification:"
if [ -d "$CALCULATED_PACKAGE_PATH" ]; then
    echo "  ✓ Calculated path exists: $CALCULATED_PACKAGE_PATH"
    PACKAGES=$(ls -1 "$CALCULATED_PACKAGE_PATH" 2>/dev/null | grep -v "^\." || echo "")
    if [ -n "$PACKAGES" ]; then
        echo "  ✓ Found packages:"
        echo "$PACKAGES" | sed 's/^/    - /'
    else
        echo "  ⚠ No packages found in $CALCULATED_PACKAGE_PATH"
    fi
else
    echo "  ✗ Calculated path does not exist: $CALCULATED_PACKAGE_PATH"
fi

if [ -d "$RELATIVE_PACKAGE_PATH" ]; then
    echo "  ✓ Relative path exists: $RELATIVE_PACKAGE_PATH"
else
    echo "  ✗ Relative path does not exist: $RELATIVE_PACKAGE_PATH"
fi

# Check for AckGen specifically
ACKGEN_CALCULATED="${CALCULATED_PACKAGE_PATH}/AckGen"
ACKGEN_RELATIVE="${RELATIVE_PACKAGE_PATH}/AckGen"

echo ""
echo "🔎 AckGen Package Location:"
if [ -d "$ACKGEN_CALCULATED" ]; then
    echo "  ✓ Found via calculated path: $ACKGEN_CALCULATED"
elif [ -d "$ACKGEN_RELATIVE" ]; then
    echo "  ✓ Found via relative path: $ACKGEN_RELATIVE"
else
    echo "  ✗ AckGen package not found in either location"
    echo ""
    echo "💡 Troubleshooting:"
    echo "  1. Make sure AckGen is added as a Swift Package dependency in Xcode"
    echo "  2. Build your project at least once so SPM downloads dependencies"
    echo "  3. Check if packages are in a different location:"
    echo "     find ~/Library/Developer/Xcode/DerivedData -name AckGen -type d 2>/dev/null"
fi

echo ""
echo "📋 Summary:"
if [ -d "$ACKGEN_CALCULATED" ] || [ -d "$ACKGEN_RELATIVE" ]; then
    echo "  ✅ AckGen package is accessible"
    echo ""
    echo "Use this in your Run Script:"
    echo "┌─────────────────────────────────────────────────────────────"
    if [ -d "$ACKGEN_CALCULATED" ]; then
        echo "│ DIR=${CALCULATED_PACKAGE_PATH}/AckGen"
    else
        echo "│ DIR=${RELATIVE_PACKAGE_PATH}/AckGen"
    fi
    echo "│ if [ -d \"\$DIR\" ]; then"
    echo "│   cd \$DIR"
    echo "│   SDKROOT=\$(xcrun --sdk macosx --show-sdk-path)"
    echo "│   swift run ackgen"
    echo "│ else"
    echo "│   echo \"warning: AckGen not found at \$DIR\""
    echo "│ fi"
    echo "└─────────────────────────────────────────────────────────────"
else
    echo "  ❌ AckGen package could not be found"
    echo "  Please verify that AckGen is installed via Swift Package Manager"
fi

echo ""
