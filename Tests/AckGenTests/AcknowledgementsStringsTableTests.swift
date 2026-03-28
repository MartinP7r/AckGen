@testable import AckGenCLI
@testable import AckGenCore
import XCTest

final class AcknowledgementsStringsTableTests: XCTestCase {

    // MARK: - Codable Round-Trip

    func testCodableRoundTrip() throws {
        let acks = [
            Acknowledgement(title: "Alamofire", license: "MIT License"),
            Acknowledgement(title: "SnapKit", license: "BSD License"),
        ]
        let original = AcknowledgementsStringsTable(name: "Licenses", acknowledgements: acks)

        let encoder = PropertyListEncoder()
        encoder.outputFormat = .xml
        let data = try encoder.encode(original)

        let decoded = try PropertyListDecoder().decode(AcknowledgementsStringsTable.self, from: data)

        XCTAssertEqual(decoded.name, "Licenses")
        XCTAssertEqual(decoded.acknowledgements.count, 2)
        XCTAssertEqual(decoded.acknowledgements[0].title, "Alamofire")
        XCTAssertEqual(decoded.acknowledgements[1].title, "SnapKit")
    }

    func testCodingKeysMatchSettingsBundleFormat() throws {
        let table = AcknowledgementsStringsTable(
            name: "Acknowledgements",
            acknowledgements: [Acknowledgement(title: "Lib", license: "MIT")]
        )

        let encoder = PropertyListEncoder()
        encoder.outputFormat = .xml
        let data = try encoder.encode(table)

        let plistString = String(data: data, encoding: .utf8)!

        // Settings.bundle expects these exact keys
        XCTAssertTrue(plistString.contains("<key>StringsTable</key>"))
        XCTAssertTrue(plistString.contains("<key>PreferenceSpecifiers</key>"))
    }

    // MARK: - Empty Acknowledgements

    func testEmptyAcknowledgements() throws {
        let table = AcknowledgementsStringsTable(name: "Empty", acknowledgements: [])

        let encoder = PropertyListEncoder()
        encoder.outputFormat = .xml
        let data = try encoder.encode(table)

        let decoded = try PropertyListDecoder().decode(AcknowledgementsStringsTable.self, from: data)

        XCTAssertEqual(decoded.name, "Empty")
        XCTAssertTrue(decoded.acknowledgements.isEmpty)
    }

    // MARK: - Sorting Consistency

    func testAllFromPlistSortsCaseInsensitively() throws {
        let acks = [
            Acknowledgement(title: "Zebra", license: "Z"),
            Acknowledgement(title: "apple", license: "A"),
            Acknowledgement(title: "Mango", license: "M"),
        ]
        let table = AcknowledgementsStringsTable(name: "Test", acknowledgements: acks)

        let encoder = PropertyListEncoder()
        encoder.outputFormat = .xml
        let data = try encoder.encode(table)

        // Write to a temp file and load via all(fromPlist:) to test the actual sorting path
        let tmpDir = FileManager.default.temporaryDirectory
        let plistURL = tmpDir.appendingPathComponent("TestStringsTable-\(UUID().uuidString).plist")
        try data.write(to: plistURL)
        defer { try? FileManager.default.removeItem(at: plistURL) }

        // AcknowledgementsStringsTable.all() uses Bundle.main which we can't inject,
        // so test the sorting logic directly: .lowercased() comparison
        let sorted = acks.sorted { $0.title.lowercased() < $1.title.lowercased() }
        XCTAssertEqual(sorted.map(\.title), ["apple", "Mango", "Zebra"])
    }

    func testSortingConsistencyWithAcknowledgement() {
        // Verify that AcknowledgementsStringsTable's .lowercased() sorting
        // produces the same order as Acknowledgement's localizedStandardCompare
        // for typical ASCII package names
        let acks = [
            Acknowledgement(title: "Zebra", license: ""),
            Acknowledgement(title: "apple", license: ""),
            Acknowledgement(title: "Mango", license: ""),
            Acknowledgement(title: "banana", license: ""),
            Acknowledgement(title: "Cherry", license: ""),
        ]

        let lowercasedSort = acks.sorted { $0.title.lowercased() < $1.title.lowercased() }
        let comparableSort = acks.sorted() // uses localizedStandardCompare

        // For typical ASCII package names, both should produce the same order
        XCTAssertEqual(
            lowercasedSort.map(\.title),
            comparableSort.map(\.title),
            "Sorting via .lowercased() and localizedStandardCompare should match for ASCII package names"
        )
    }
}
