@testable import AckGenCLI
@testable import AckGenCore
import XCTest

final class PlistEncodingTests: XCTestCase {

    private let encoder: PropertyListEncoder = {
        let encoder = PropertyListEncoder()
        encoder.outputFormat = .xml
        return encoder
    }()

    // MARK: - Standard format (array of Acknowledgement)

    func testStandardFormatEncodesAsArray() throws {
        let acks = [
            Acknowledgement(title: "Alamofire", license: "MIT"),
            Acknowledgement(title: "SnapKit", license: "BSD"),
        ]

        let data = try encoder.encode(acks)
        let decoded = try PropertyListDecoder().decode([Acknowledgement].self, from: data)

        XCTAssertEqual(decoded.count, 2)
        XCTAssertEqual(decoded[0].title, "Alamofire")
        XCTAssertEqual(decoded[1].title, "SnapKit")
    }

    func testStandardFormatPreservesLicenseText() throws {
        let multilineLicense = """
        MIT License

        Copyright (c) 2024 Example

        Permission is hereby granted, free of charge...
        """
        let acks = [Acknowledgement(title: "Example", license: multilineLicense)]

        let data = try encoder.encode(acks)
        let decoded = try PropertyListDecoder().decode([Acknowledgement].self, from: data)

        XCTAssertEqual(decoded.first?.license, multilineLicense)
    }

    // MARK: - Settings.bundle format

    func testSettingsFormatEncodesWithCorrectKeys() throws {
        let acks = [Acknowledgement(title: "Lib", license: "MIT")]
        let table = AcknowledgementsStringsTable(name: "Acknowledgements", acknowledgements: acks)

        let data = try encoder.encode(table)
        let plist = try PropertyListSerialization.propertyList(from: data, format: nil) as! [String: Any]

        XCTAssertEqual(plist["StringsTable"] as? String, "Acknowledgements")
        XCTAssertNotNil(plist["PreferenceSpecifiers"] as? [[String: String]])
    }

    func testSettingsFormatCustomTitle() throws {
        let acks = [Acknowledgement(title: "Lib", license: "MIT")]
        let table = AcknowledgementsStringsTable(name: "Licenses", acknowledgements: acks)

        let data = try encoder.encode(table)
        let decoded = try PropertyListDecoder().decode(AcknowledgementsStringsTable.self, from: data)

        XCTAssertEqual(decoded.name, "Licenses")
    }

    // MARK: - Output file writing

    func testWritesPlistToFile() throws {
        let acks = [
            Acknowledgement(title: "PackageA", license: "MIT"),
            Acknowledgement(title: "PackageB", license: "Apache"),
        ]

        let tmpDir = FileManager.default.temporaryDirectory
        let plistURL = tmpDir.appendingPathComponent("PlistEncodingTest-\(UUID().uuidString).plist")
        defer { try? FileManager.default.removeItem(at: plistURL) }

        let data = try encoder.encode(acks)
        try data.write(to: plistURL)

        // Read back and verify
        let readData = try Data(contentsOf: plistURL)
        let decoded = try PropertyListDecoder().decode([Acknowledgement].self, from: readData)

        XCTAssertEqual(decoded.count, 2)
        XCTAssertEqual(decoded[0].title, "PackageA")
    }
}
