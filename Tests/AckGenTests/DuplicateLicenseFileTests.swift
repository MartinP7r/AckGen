//
//  DuplicateLicenseFileTests.swift
//  AckGenTests
//

import XCTest
import Foundation
@testable import AckGenCore

final class DuplicateLicenseFileTests: XCTestCase {

    var tempDir: URL!
    var packageCachePath: URL!

    override func setUp() {
        super.setUp()
        tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        packageCachePath = tempDir.appendingPathComponent("SourcePackages/checkouts")
        try? FileManager.default.createDirectory(at: packageCachePath, withIntermediateDirectories: true)
    }

    override func tearDown() {
        super.tearDown()
        try? FileManager.default.removeItem(at: tempDir)
    }

    /// Scans the package cache path for license files, mimicking the CLI logic.
    /// Uses break after first match per package (matching production behavior).
    private func scanForLicenses(shouldBreak: Bool = true) throws -> [Acknowledgement] {
        let licenseFiles: [String] = ["LICENSE", "LICENSE.txt", "LICENSE.md"]
        let fileManager = FileManager.default
        let packageDirectories = try fileManager.contentsOfDirectory(atPath: packageCachePath.path)
        var acknowledgements = [Acknowledgement]()

        for pkgDir in packageDirectories where pkgDir.prefix(1) != "." {
            for file in licenseFiles {
                guard let data = fileManager.contents(atPath: "\(packageCachePath.path)/\(pkgDir)/\(file)") else { continue }
                guard let license = String(data: data, encoding: .utf8) else { continue }
                acknowledgements.append(Acknowledgement(title: pkgDir, license: license))
                if shouldBreak { break }
            }
        }

        return acknowledgements
    }

    func testPackageWithMultipleLicenseFilesGeneratesOnlyOneAcknowledgement() throws {
        let packageDir = packageCachePath.appendingPathComponent("TestPackage")
        try FileManager.default.createDirectory(at: packageDir, withIntermediateDirectories: true)

        try "MIT License - from LICENSE".write(to: packageDir.appendingPathComponent("LICENSE"), atomically: true, encoding: .utf8)
        try "MIT License - from LICENSE.txt".write(to: packageDir.appendingPathComponent("LICENSE.txt"), atomically: true, encoding: .utf8)
        try "MIT License - from LICENSE.md".write(to: packageDir.appendingPathComponent("LICENSE.md"), atomically: true, encoding: .utf8)

        let acknowledgements = try scanForLicenses()

        XCTAssertEqual(acknowledgements.count, 1, "Should only create one acknowledgement per package")
        XCTAssertEqual(acknowledgements[0].title, "TestPackage")
        XCTAssertEqual(acknowledgements[0].license, "MIT License - from LICENSE", "Should use first matching license file")
    }

    func testMultiplePackagesWithMultipleLicenseFiles() throws {
        let package1Dir = packageCachePath.appendingPathComponent("Package1")
        let package2Dir = packageCachePath.appendingPathComponent("Package2")

        try FileManager.default.createDirectory(at: package1Dir, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: package2Dir, withIntermediateDirectories: true)

        try "License for Package1".write(to: package1Dir.appendingPathComponent("LICENSE"), atomically: true, encoding: .utf8)
        try "License txt for Package1".write(to: package1Dir.appendingPathComponent("LICENSE.txt"), atomically: true, encoding: .utf8)

        try "License txt for Package2".write(to: package2Dir.appendingPathComponent("LICENSE.txt"), atomically: true, encoding: .utf8)
        try "License md for Package2".write(to: package2Dir.appendingPathComponent("LICENSE.md"), atomically: true, encoding: .utf8)

        let acknowledgements = try scanForLicenses()

        XCTAssertEqual(acknowledgements.count, 2, "Should have one acknowledgement per package")

        let ack1 = acknowledgements.first { $0.title == "Package1" }
        let ack2 = acknowledgements.first { $0.title == "Package2" }

        XCTAssertEqual(ack1?.license, "License for Package1", "Package1 should use LICENSE (first in order)")
        XCTAssertEqual(ack2?.license, "License txt for Package2", "Package2 should use LICENSE.txt (first available)")
    }

    func testWithoutBreakWouldCreateDuplicates() throws {
        let packageDir = packageCachePath.appendingPathComponent("DuplicateTest")
        try FileManager.default.createDirectory(at: packageDir, withIntermediateDirectories: true)

        try "License 1".write(to: packageDir.appendingPathComponent("LICENSE"), atomically: true, encoding: .utf8)
        try "License 2".write(to: packageDir.appendingPathComponent("LICENSE.txt"), atomically: true, encoding: .utf8)

        // Demonstrates the bug that would occur without break
        let acknowledgements = try scanForLicenses(shouldBreak: false)

        XCTAssertEqual(acknowledgements.count, 2, "Without break, duplicates are created")
        XCTAssertEqual(acknowledgements[0].title, acknowledgements[1].title)
    }
}
