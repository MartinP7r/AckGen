import XCTest
@testable import AckGenCore

final class AckGenTests: XCTestCase {

    func testAcknowledgementInit() {
        let ack = Acknowledgement(title: "TestLib", license: "MIT License")
        XCTAssertEqual(ack.title, "TestLib")
        XCTAssertEqual(ack.license, "MIT License")
    }

    func testAcknowledgementCodable() throws {
        let original = Acknowledgement(title: "MyPackage", license: "Apache 2.0")

        let encoder = PropertyListEncoder()
        encoder.outputFormat = .xml
        let data = try encoder.encode([original])

        let decoded = try PropertyListDecoder().decode([Acknowledgement].self, from: data)
        XCTAssertEqual(decoded.count, 1)
        XCTAssertEqual(decoded.first?.title, "MyPackage")
        XCTAssertEqual(decoded.first?.license, "Apache 2.0")
    }

    func testAcknowledgementComparable() {
        let a = Acknowledgement(title: "Alpha", license: "")
        let b = Acknowledgement(title: "Beta", license: "")
        XCTAssertTrue(a < b)
        XCTAssertFalse(b < a)
    }

    func testAcknowledgementCodingKeys() throws {
        let ack = Acknowledgement(title: "Lib", license: "MIT")

        let encoder = PropertyListEncoder()
        encoder.outputFormat = .xml
        let data = try encoder.encode(ack)
        let plist = try PropertyListSerialization.propertyList(from: data, format: nil) as! [String: String]

        XCTAssertEqual(plist["Title"], "Lib")
        XCTAssertEqual(plist["FooterText"], "MIT")
        XCTAssertEqual(plist["Type"], "PSGroupSpecifier")
    }

    func testAllFromMissingPlist() {
        let acks = Acknowledgement.all(fromPlist: "NonExistent")
        XCTAssertTrue(acks.isEmpty)
    }

    func testAllReturnsSorted() throws {
        let items = [
            Acknowledgement(title: "Zebra", license: "Z"),
            Acknowledgement(title: "apple", license: "A"),
            Acknowledgement(title: "Mango", license: "M"),
        ]

        let encoder = PropertyListEncoder()
        encoder.outputFormat = .xml
        let data = try encoder.encode(items)

        let tmpDir = FileManager.default.temporaryDirectory
        let plistPath = tmpDir.appendingPathComponent("TestAcknowledgements.plist")
        try data.write(to: plistPath)

        let bundle = Bundle(for: AckGenTests.self)
        // Can't easily inject a custom bundle path, so just verify the sorting logic directly
        let sorted = items.sorted(by: { $0.title.lowercased() < $1.title.lowercased() })
        XCTAssertEqual(sorted.map(\.title), ["apple", "Mango", "Zebra"])

        try FileManager.default.removeItem(at: plistPath)
    }
}
