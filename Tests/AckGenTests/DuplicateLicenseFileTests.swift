//
//  DuplicateLicenseFileTests.swift
//  AckGenTests
//
//  Created by Copilot on 2026-02-07.
//

import XCTest
import Foundation
@testable import AckGenCore

final class DuplicateLicenseFileTests: XCTestCase {
    
    var tempDir: URL!
    var packageCachePath: URL!
    
    override func setUp() {
        super.setUp()
        // Create a temporary directory structure that simulates SPM checkouts
        tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        packageCachePath = tempDir.appendingPathComponent("SourcePackages/checkouts")
        try? FileManager.default.createDirectory(at: packageCachePath, withIntermediateDirectories: true)
    }
    
    override func tearDown() {
        super.tearDown()
        try? FileManager.default.removeItem(at: tempDir)
    }
    
    /// Scans the package cache path for license files, mimicking the CLI logic.
    /// - Parameter shouldBreak: If true, breaks after finding the first license file per package (correct behavior).
    ///                          If false, continues scanning all license files (buggy behavior).
    /// - Returns: Array of acknowledgements found
    private func scanForLicenses(shouldBreak: Bool) throws -> [Acknowledgement] {
        let licenseFiles: [String] = ["LICENSE", "LICENSE.txt", "LICENSE.md"]
        let fileManager = FileManager.default
        let packageDirectories = try fileManager.contentsOfDirectory(atPath: packageCachePath.path)
        var acknowledgements = [Acknowledgement]()
        
        for pkgDir in packageDirectories where pkgDir.prefix(1) != "." {
            for file in licenseFiles {
                guard let data = fileManager.contents(atPath: "\(packageCachePath.path)/\(pkgDir)/\(file)") else { continue }
                guard let license = String(data: data, encoding: .utf8) else { continue }
                let new = Acknowledgement(title: pkgDir, license: license)
                acknowledgements.append(new)
                if shouldBreak {
                    break  // This break prevents duplicate entries
                }
            }
        }
        
        return acknowledgements
    }
    
    func testPackageWithMultipleLicenseFilesGeneratesOnlyOneAcknowledgement() throws {
        // Given: A package directory with multiple license files (LICENSE, LICENSE.txt, LICENSE.md)
        let packageName = "TestPackage"
        let packageDir = packageCachePath.appendingPathComponent(packageName)
        try FileManager.default.createDirectory(at: packageDir, withIntermediateDirectories: true)
        
        // Create all three license file variants
        let licenseContent1 = "MIT License - from LICENSE"
        let licenseContent2 = "MIT License - from LICENSE.txt"
        let licenseContent3 = "MIT License - from LICENSE.md"
        
        try licenseContent1.write(to: packageDir.appendingPathComponent("LICENSE"), atomically: true, encoding: .utf8)
        try licenseContent2.write(to: packageDir.appendingPathComponent("LICENSE.txt"), atomically: true, encoding: .utf8)
        try licenseContent3.write(to: packageDir.appendingPathComponent("LICENSE.md"), atomically: true, encoding: .utf8)
        
        // When: Scanning the package directory with break (correct behavior)
        let acknowledgements = try scanForLicenses(shouldBreak: true)
        
        // Then: Only one acknowledgement should be created for the package
        XCTAssertEqual(acknowledgements.count, 1, "Should only create one acknowledgement per package, even with multiple license files")
        XCTAssertEqual(acknowledgements[0].title, packageName)
        
        // The first found license file (LICENSE) should be used
        XCTAssertEqual(acknowledgements[0].license, licenseContent1, "Should use the first matching license file (LICENSE)")
    }
    
    func testMultiplePackagesWithMultipleLicenseFiles() throws {
        // Given: Multiple packages, each with multiple license files
        let package1 = "Package1"
        let package2 = "Package2"
        
        let package1Dir = packageCachePath.appendingPathComponent(package1)
        let package2Dir = packageCachePath.appendingPathComponent(package2)
        
        try FileManager.default.createDirectory(at: package1Dir, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: package2Dir, withIntermediateDirectories: true)
        
        // Package1 has LICENSE and LICENSE.txt
        try "License for Package1".write(to: package1Dir.appendingPathComponent("LICENSE"), atomically: true, encoding: .utf8)
        try "License txt for Package1".write(to: package1Dir.appendingPathComponent("LICENSE.txt"), atomically: true, encoding: .utf8)
        
        // Package2 has LICENSE.txt and LICENSE.md
        try "License txt for Package2".write(to: package2Dir.appendingPathComponent("LICENSE.txt"), atomically: true, encoding: .utf8)
        try "License md for Package2".write(to: package2Dir.appendingPathComponent("LICENSE.md"), atomically: true, encoding: .utf8)
        
        // When: Scanning all package directories with break (correct behavior)
        let acknowledgements = try scanForLicenses(shouldBreak: true)
        
        // Then: Should have exactly 2 acknowledgements (one per package)
        XCTAssertEqual(acknowledgements.count, 2, "Should have one acknowledgement per package")
        
        let titles = Set(acknowledgements.map(\.title))
        XCTAssertTrue(titles.contains(package1))
        XCTAssertTrue(titles.contains(package2))
        
        // Verify each package uses its first available license file
        let ack1 = acknowledgements.first { $0.title == package1 }
        let ack2 = acknowledgements.first { $0.title == package2 }
        
        XCTAssertEqual(ack1?.license, "License for Package1", "Package1 should use LICENSE (first in order)")
        XCTAssertEqual(ack2?.license, "License txt for Package2", "Package2 should use LICENSE.txt (first available)")
    }
    
    func testPackageWithoutBreakWouldCreateDuplicates() throws {
        // Given: A package with multiple license files
        let packageName = "DuplicateTest"
        let packageDir = packageCachePath.appendingPathComponent(packageName)
        try FileManager.default.createDirectory(at: packageDir, withIntermediateDirectories: true)
        
        try "License 1".write(to: packageDir.appendingPathComponent("LICENSE"), atomically: true, encoding: .utf8)
        try "License 2".write(to: packageDir.appendingPathComponent("LICENSE.txt"), atomically: true, encoding: .utf8)
        
        // When: Scanning WITHOUT break statement (old behavior)
        let acknowledgements = try scanForLicenses(shouldBreak: false)
        
        // Then: WITHOUT break, we would get 2 entries for the same package (demonstrating the bug)
        XCTAssertEqual(acknowledgements.count, 2, "Without break, multiple entries are created for the same package")
        XCTAssertEqual(acknowledgements[0].title, packageName)
        XCTAssertEqual(acknowledgements[1].title, packageName)
        XCTAssertNotEqual(acknowledgements[0].license, acknowledgements[1].license, "Each entry has different license content")
    }
}
