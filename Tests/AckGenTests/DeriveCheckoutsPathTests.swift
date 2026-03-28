@testable import AckGenCLI
import XCTest

final class DeriveCheckoutsPathTests: XCTestCase {

    // MARK: - Standard Xcode paths

    func testStandardDerivedDataPath() {
        let tempDir = "/Users/dev/Library/Developer/Xcode/DerivedData/MyApp-abc123/Build/Intermediates.noindex/MyApp.build"

        let result = deriveCheckoutsPath(from: tempDir)

        XCTAssertEqual(
            result,
            "/Users/dev/Library/Developer/Xcode/DerivedData/MyApp-abc123/SourcePackages/checkouts"
        )
    }

    // MARK: - Archive builds (deeper path, issue #6)

    func testArchiveBuildPath() {
        let tempDir = "/Users/dev/Library/Developer/Xcode/DerivedData/MyApp-abc123/Build/Intermediates.noindex/ArchiveIntermediates/MyApp/IntermediateBuildFilesPath/MyApp.build"

        let result = deriveCheckoutsPath(from: tempDir)

        XCTAssertEqual(
            result,
            "/Users/dev/Library/Developer/Xcode/DerivedData/MyApp-abc123/SourcePackages/checkouts"
        )
    }

    // MARK: - "Build" in directory name (bug #40)

    func testBuildInUsername() {
        let tempDir = "/Users/BuildEngineer/Library/Developer/Xcode/DerivedData/MyApp-abc123/Build/Intermediates.noindex/MyApp.build"

        let result = deriveCheckoutsPath(from: tempDir)

        // Should use the LAST /Build/, not the one in the username
        XCTAssertEqual(
            result,
            "/Users/BuildEngineer/Library/Developer/Xcode/DerivedData/MyApp-abc123/SourcePackages/checkouts"
        )
    }

    func testBuildInProjectName() {
        let tempDir = "/Users/dev/Projects/BuildTools/Library/Developer/Xcode/DerivedData/App-xyz/Build/Intermediates.noindex/App.build"

        let result = deriveCheckoutsPath(from: tempDir)

        XCTAssertEqual(
            result,
            "/Users/dev/Projects/BuildTools/Library/Developer/Xcode/DerivedData/App-xyz/SourcePackages/checkouts"
        )
    }

    func testMultipleBuildSegments() {
        // Pathological case: "Build" appears multiple times
        let tempDir = "/Users/dev/Build/Projects/DerivedData/App-abc/Build/Intermediates.noindex/App.build"

        let result = deriveCheckoutsPath(from: tempDir)

        // Last /Build/ wins
        XCTAssertEqual(
            result,
            "/Users/dev/Build/Projects/DerivedData/App-abc/SourcePackages/checkouts"
        )
    }

    // MARK: - Fallback (no /Build/ segment)

    func testNoBuildSegmentFallback() {
        // Unlikely in practice, but tests the fallback behavior
        let tempDir = "/some/unusual/path/without/build/segment"

        let result = deriveCheckoutsPath(from: tempDir)

        // Falls back to appending /SourcePackages/checkouts to the full path
        XCTAssertEqual(
            result,
            "/some/unusual/path/without/build/segment/SourcePackages/checkouts"
        )
    }
}
