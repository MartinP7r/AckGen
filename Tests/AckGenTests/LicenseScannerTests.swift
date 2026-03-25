@testable import AckGenCLI
import XCTest

final class LicenseScannerTests: XCTestCase {
    private var tempDir: String!
    private let fman = FileManager.default

    override func setUp() {
        super.setUp()
        tempDir = NSTemporaryDirectory() + "AckGenTests-\(UUID().uuidString)"
        try! fman.createDirectory(atPath: tempDir, withIntermediateDirectories: true)
    }

    override func tearDown() {
        try? fman.removeItem(atPath: tempDir)
        super.tearDown()
    }

    // MARK: - Helpers

    private func createPackage(_ name: String, licenseFile: String = "LICENSE", content: String = "MIT License") {
        let pkgPath = "\(tempDir!)/\(name)"
        try! fman.createDirectory(atPath: pkgPath, withIntermediateDirectories: true)
        let data = content.data(using: .utf8)!
        fman.createFile(atPath: "\(pkgPath)/\(licenseFile)", contents: data)
    }

    private func createPackageWithInvalidUTF8(_ name: String) {
        let pkgPath = "\(tempDir!)/\(name)"
        try! fman.createDirectory(atPath: pkgPath, withIntermediateDirectories: true)
        // Invalid UTF-8: 0xFF 0xFE are not valid UTF-8 start bytes
        let invalidData = Data([0xFF, 0xFE, 0x80, 0x81])
        fman.createFile(atPath: "\(pkgPath)/LICENSE", contents: invalidData)
    }

    // MARK: - Tests

    func testScanFindsLicenseFiles() throws {
        createPackage("Alamofire", content: "MIT License - Alamofire")
        createPackage("SnapKit", content: "MIT License - SnapKit")

        let result = try LicenseScanner.scan(checkoutsPath: tempDir)

        XCTAssertEqual(result.acknowledgements.count, 2)
        XCTAssertTrue(result.skippedFiles.isEmpty)
    }

    func testScanFindsLicenseTxtVariant() throws {
        let pkgPath = "\(tempDir!)/SomePackage"
        try fman.createDirectory(atPath: pkgPath, withIntermediateDirectories: true)
        fman.createFile(atPath: "\(pkgPath)/LICENSE.txt", contents: "BSD License".data(using: .utf8)!)

        let result = try LicenseScanner.scan(checkoutsPath: tempDir)

        XCTAssertEqual(result.acknowledgements.count, 1)
        XCTAssertEqual(result.acknowledgements.first?.title, "SomePackage")
    }

    func testScanSkipsHiddenDirectories() throws {
        createPackage("Visible")
        createPackage(".hidden")

        let result = try LicenseScanner.scan(checkoutsPath: tempDir)

        XCTAssertEqual(result.acknowledgements.count, 1)
        XCTAssertEqual(result.acknowledgements.first?.title, "Visible")
    }

    func testScanBreaksAfterFirstLicenseFound() throws {
        // Package has both LICENSE and LICENSE.md — should only produce one entry
        let pkgPath = "\(tempDir!)/DualLicense"
        try fman.createDirectory(atPath: pkgPath, withIntermediateDirectories: true)
        fman.createFile(atPath: "\(pkgPath)/LICENSE", contents: "MIT".data(using: .utf8)!)
        fman.createFile(atPath: "\(pkgPath)/LICENSE.md", contents: "# MIT".data(using: .utf8)!)

        let result = try LicenseScanner.scan(checkoutsPath: tempDir)

        XCTAssertEqual(result.acknowledgements.count, 1)
        XCTAssertEqual(result.acknowledgements.first?.license, "MIT")
    }

    func testScanTracksInvalidUTF8Files() throws {
        createPackageWithInvalidUTF8("BadEncoding")

        let result = try LicenseScanner.scan(checkoutsPath: tempDir)

        XCTAssertTrue(result.acknowledgements.isEmpty)
        XCTAssertEqual(result.skippedFiles.count, 1)
        XCTAssertEqual(result.skippedFiles.first?.package, "BadEncoding")
        XCTAssertEqual(result.skippedFiles.first?.reason, "invalid UTF-8 encoding")
    }

    func testScanReturnsEmptyForNoPackages() throws {
        // tempDir exists but has no subdirectories
        let result = try LicenseScanner.scan(checkoutsPath: tempDir)

        XCTAssertTrue(result.acknowledgements.isEmpty)
        XCTAssertTrue(result.skippedFiles.isEmpty)
    }

    func testScanSkipsPackagesWithNoLicenseFile() throws {
        // Package directory exists but has no LICENSE file
        let pkgPath = "\(tempDir!)/NoLicense"
        try fman.createDirectory(atPath: pkgPath, withIntermediateDirectories: true)
        fman.createFile(atPath: "\(pkgPath)/README.md", contents: "Hello".data(using: .utf8)!)

        createPackage("HasLicense")

        let result = try LicenseScanner.scan(checkoutsPath: tempDir)

        XCTAssertEqual(result.acknowledgements.count, 1)
        XCTAssertEqual(result.acknowledgements.first?.title, "HasLicense")
    }
}
