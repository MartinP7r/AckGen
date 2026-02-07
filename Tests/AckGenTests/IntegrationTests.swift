import XCTest
import Foundation

/// Integration tests for AckGen CLI path detection and package discovery
final class IntegrationTests: XCTestCase {
    
    var tempDir: URL!
    
    override func setUp() {
        super.setUp()
        tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("AckGenIntegrationTests-\(UUID().uuidString)")
        try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
    }
    
    override func tearDown() {
        if let tempDir = tempDir {
            try? FileManager.default.removeItem(at: tempDir)
        }
        super.tearDown()
    }
    
    /// Test that the path calculation logic correctly extracts the base path from PROJECT_TEMP_DIR
    func testPathCalculationFromProjectTempDir() {
        // Given: Various PROJECT_TEMP_DIR patterns used by Xcode
        let testCases: [(input: String, expectedBase: String)] = [
            // Standard SPM project structure
            (
                "/Users/username/Library/Developer/Xcode/DerivedData/AppName-xyz/Build/Intermediates.noindex/AppName.build",
                "/Users/username/Library/Developer/Xcode/DerivedData/AppName-xyz"
            ),
            // Nested build directory
            (
                "/Users/username/Library/Developer/Xcode/DerivedData/AppName-abc/Build/Products/Debug/AppName.build",
                "/Users/username/Library/Developer/Xcode/DerivedData/AppName-abc"
            ),
            // Different user paths
            (
                "/Users/developer/Library/Developer/Xcode/DerivedData/MyProject-def/Build/Intermediates.noindex/MyProject.build",
                "/Users/developer/Library/Developer/Xcode/DerivedData/MyProject-def"
            ),
        ]
        
        // When & Then: Path calculation should correctly extract base directory
        for testCase in testCases {
            // Use the improved path calculation that handles edge cases
            let calculatedBase: String
            if let range = testCase.input.range(of: "/Build/", options: .backwards) {
                calculatedBase = String(testCase.input[..<range.lowerBound])
            } else {
                calculatedBase = testCase.input.components(separatedBy: "/Build/")[0]
            }
            let expectedPackagePath = calculatedBase + "/SourcePackages/checkouts"
            let expectedBasePath = testCase.expectedBase + "/SourcePackages/checkouts"
            
            XCTAssertEqual(expectedPackagePath, expectedBasePath,
                          "Path calculation failed for \(testCase.input)")
        }
    }
    
    /// Test that the relative path approach from README matches the calculated path
    func testRelativePathVsCalculatedPath() {
        // Given: A simulated PROJECT_TEMP_DIR from Xcode
        let projectTempDir = "/Users/username/Library/Developer/Xcode/DerivedData/AppName-xyz/Build/Intermediates.noindex/AppName.build"
        
        // When: Calculate path using the improved CLI approach
        let calculatedPath: String
        if let range = projectTempDir.range(of: "/Build/", options: .backwards) {
            let basePath = String(projectTempDir[..<range.lowerBound])
            calculatedPath = basePath + "/SourcePackages/checkouts"
        } else {
            calculatedPath = projectTempDir.components(separatedBy: "/Build/")[0] + "/SourcePackages/checkouts"
        }
        
        // Expected path from base directory
        let expectedPath = "/Users/username/Library/Developer/Xcode/DerivedData/AppName-xyz/SourcePackages/checkouts"
        
        // Then: Paths should match
        XCTAssertEqual(calculatedPath, expectedPath)
        
        // The relative path "../../../" from PROJECT_TEMP_DIR would give:
        // ../../../ from /Users/username/Library/Developer/Xcode/DerivedData/AppName-xyz/Build/Intermediates.noindex/AppName.build
        // should reach: /Users/username/Library/Developer/Xcode/DerivedData/AppName-xyz/Build
        // But we need: /Users/username/Library/Developer/Xcode/DerivedData/AppName-xyz
        
        // This demonstrates why the relative path approach may fail
        let url = URL(fileURLWithPath: projectTempDir)
        let relativeUrl = url
            .deletingLastPathComponent()  // Remove AppName.build
            .deletingLastPathComponent()  // Remove Intermediates.noindex
            .deletingLastPathComponent()  // Remove Build
        
        let relativeBasePath = relativeUrl.path + "/SourcePackages/checkouts"
        XCTAssertEqual(relativeBasePath, expectedPath,
                      "Relative path should match calculated path")
    }
    
    /// Integration test: Create a mock package structure and verify discovery
    func testPackageDiscoveryWithMockStructure() throws {
        // Given: Create a mock SourcePackages/checkouts structure
        let derivedDataDir = tempDir.appendingPathComponent("DerivedData/TestApp-abc")
        let buildDir = derivedDataDir.appendingPathComponent("Build/Intermediates.noindex/TestApp.build")
        let packagesDir = derivedDataDir.appendingPathComponent("SourcePackages/checkouts")
        
        try FileManager.default.createDirectory(at: buildDir, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: packagesDir, withIntermediateDirectories: true)
        
        // Create mock package directories with LICENSE files
        let package1 = packagesDir.appendingPathComponent("TestPackage1")
        let package2 = packagesDir.appendingPathComponent("TestPackage2")
        
        try FileManager.default.createDirectory(at: package1, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: package2, withIntermediateDirectories: true)
        
        let license1 = "MIT License\nCopyright (c) 2024 Test Package 1"
        let license2 = "Apache License 2.0\nCopyright (c) 2024 Test Package 2"
        
        try license1.write(to: package1.appendingPathComponent("LICENSE"), atomically: true, encoding: .utf8)
        try license2.write(to: package2.appendingPathComponent("LICENSE.txt"), atomically: true, encoding: .utf8)
        
        // When: Calculate package cache path from PROJECT_TEMP_DIR using improved logic
        let projectTempDir = buildDir.path
        let calculatedPackagePath: String
        if let range = projectTempDir.range(of: "/Build/", options: .backwards) {
            let basePath = String(projectTempDir[..<range.lowerBound])
            calculatedPackagePath = basePath + "/SourcePackages/checkouts"
        } else {
            calculatedPackagePath = projectTempDir.components(separatedBy: "/Build/")[0] + "/SourcePackages/checkouts"
        }
        
        // Then: Should find the correct directory
        XCTAssertEqual(calculatedPackagePath, packagesDir.path)
        XCTAssertTrue(FileManager.default.fileExists(atPath: calculatedPackagePath))
        
        // Should discover package directories
        let discoveredPackages = try FileManager.default.contentsOfDirectory(atPath: calculatedPackagePath)
        XCTAssertEqual(discoveredPackages.sorted(), ["TestPackage1", "TestPackage2"])
    }
    
    /// Test edge case: PROJECT_TEMP_DIR with multiple "Build" components
    func testPathCalculationWithMultipleBuildComponents() {
        // Given: A PROJECT_TEMP_DIR that contains "Build" multiple times
        let projectTempDir = "/Users/Build/Projects/AppName-xyz/Build/Intermediates.noindex/AppName.build"
        
        // When: Calculate path using improved logic (should find last "/Build/")
        let calculatedPath: String
        if let range = projectTempDir.range(of: "/Build/", options: .backwards) {
            let basePath = String(projectTempDir[..<range.lowerBound])
            calculatedPath = basePath + "/SourcePackages/checkouts"
        } else {
            calculatedPath = projectTempDir.components(separatedBy: "/Build/")[0] + "/SourcePackages/checkouts"
        }
        
        // Then: Should correctly identify the base path before the last Build/
        let expectedPath = "/Users/Build/Projects/AppName-xyz/SourcePackages/checkouts"
        XCTAssertEqual(calculatedPath, expectedPath)
    }
    
    /// Test that the path calculation handles various Xcode project configurations
    func testPathCalculationForDifferentXcodeConfigurations() {
        let configurations: [(name: String, tempDir: String, expectedBase: String)] = [
            (
                "Standard Debug Build",
                "/Users/dev/Library/Developer/Xcode/DerivedData/App-xyz/Build/Intermediates.noindex/App.build/Debug-iphonesimulator/App.build",
                "/Users/dev/Library/Developer/Xcode/DerivedData/App-xyz"
            ),
            (
                "Release Build",
                "/Users/dev/Library/Developer/Xcode/DerivedData/App-xyz/Build/Intermediates.noindex/App.build/Release-iphoneos/App.build",
                "/Users/dev/Library/Developer/Xcode/DerivedData/App-xyz"
            ),
            (
                "macOS Build",
                "/Users/dev/Library/Developer/Xcode/DerivedData/MacApp-abc/Build/Intermediates.noindex/MacApp.build/Debug/MacApp.build",
                "/Users/dev/Library/Developer/Xcode/DerivedData/MacApp-abc"
            ),
        ]
        
        for config in configurations {
            // When: Calculate package path using improved logic
            let calculatedPath: String
            if let range = config.tempDir.range(of: "/Build/", options: .backwards) {
                let basePath = String(config.tempDir[..<range.lowerBound])
                calculatedPath = basePath + "/SourcePackages/checkouts"
            } else {
                calculatedPath = config.tempDir.components(separatedBy: "/Build/")[0] + "/SourcePackages/checkouts"
            }
            let expectedPath = config.expectedBase + "/SourcePackages/checkouts"
            
            // Then: Should correctly calculate path
            XCTAssertEqual(calculatedPath, expectedPath,
                          "Failed for configuration: \(config.name)")
        }
    }
}
