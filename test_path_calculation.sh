#!/bin/bash
# Test script to verify path calculation works correctly
# This mimics what the Run Script phase does

echo "Testing AckGen Path Calculation"
echo "================================"
echo ""

# Test cases with different PROJECT_TEMP_DIR structures
test_cases=(
    "/Users/username/Library/Developer/Xcode/DerivedData/AppName-xyz/Build/Intermediates.noindex/AppName.build"
    "/Users/dev/Library/Developer/Xcode/DerivedData/App-xyz/Build/Intermediates.noindex/App.build/Debug-iphonesimulator/App.build"
    "/Users/Build/Projects/AppName-xyz/Build/Intermediates.noindex/AppName.build"
)

expected_bases=(
    "/Users/username/Library/Developer/Xcode/DerivedData/AppName-xyz"
    "/Users/dev/Library/Developer/Xcode/DerivedData/App-xyz"
    "/Users/Build/Projects/AppName-xyz"
)

passed=0
failed=0

for i in "${!test_cases[@]}"; do
    PROJECT_TEMP_DIR="${test_cases[$i]}"
    EXPECTED_BASE="${expected_bases[$i]}"
    
    # Calculate base directory (same logic as in README - improved version)
    BASE_DIR="${PROJECT_TEMP_DIR%/Build/*}"
    PACKAGE_PATH="$BASE_DIR/SourcePackages/checkouts"
    
    EXPECTED_PACKAGE_PATH="$EXPECTED_BASE/SourcePackages/checkouts"
    
    if [ "$PACKAGE_PATH" = "$EXPECTED_PACKAGE_PATH" ]; then
        echo "✅ Test $((i+1)): PASSED"
        echo "   Input: $PROJECT_TEMP_DIR"
        echo "   Output: $PACKAGE_PATH"
        passed=$((passed + 1))
    else
        echo "❌ Test $((i+1)): FAILED"
        echo "   Input: $PROJECT_TEMP_DIR"
        echo "   Expected: $EXPECTED_PACKAGE_PATH"
        echo "   Got: $PACKAGE_PATH"
        failed=$((failed + 1))
    fi
    echo ""
done

# Test edge case: multiple "Build" in path
echo "Testing edge case: Multiple 'Build' in path"
PROJECT_TEMP_DIR="/Users/Build/Projects/AppName-xyz/Build/Intermediates.noindex/AppName.build"
BASE_DIR="${PROJECT_TEMP_DIR%/Build/*}"
EXPECTED="/Users/Build/Projects/AppName-xyz"

if [ "$BASE_DIR" = "$EXPECTED" ]; then
    echo "✅ Edge case: PASSED (correctly uses first /Build/)"
    echo "   Input: $PROJECT_TEMP_DIR"
    echo "   Output: $BASE_DIR"
    passed=$((passed + 1))
else
    echo "❌ Edge case: FAILED"
    echo "   Expected: $EXPECTED"
    echo "   Got: $BASE_DIR"
    failed=$((failed + 1))
fi
echo ""

# Summary
echo "================================"
echo "Test Summary:"
echo "  Passed: $passed"
echo "  Failed: $failed"
echo ""

if [ $failed -eq 0 ]; then
    echo "✅ All tests passed!"
    exit 0
else
    echo "❌ Some tests failed"
    exit 1
fi
