//
//  AcknowledgementTests.swift
//  AckGenTests
//
//  Created by Martin Pfundmair on 2026-01-04.
//

import XCTest
@testable import AckGenCore

final class AcknowledgementTests: XCTestCase {

    func testInitialization() {
        let ack = Acknowledgement(title: "TestPackage", license: "MIT License")
        XCTAssertEqual(ack.title, "TestPackage")
        XCTAssertEqual(ack.license, "MIT License")
        XCTAssertEqual(ack.type, "PSGroupSpecifier")
    }

    func testComparable() {
        let ackA = Acknowledgement(title: "A", license: "")
        let ackB = Acknowledgement(title: "B", license: "")
        let ackZ = Acknowledgement(title: "Z", license: "")

        XCTAssertTrue(ackA < ackB)
        XCTAssertTrue(ackB < ackZ)
        XCTAssertFalse(ackB < ackA)
    }

    func testSortingIsCaseSensitive() {
        // Note: Comparable implementation uses case-sensitive sorting
        // This differs from Acknowledgement.all() which uses case-insensitive
        let acks = [
            Acknowledgement(title: "Zebra", license: "License 1"),
            Acknowledgement(title: "apple", license: "License 2"),
            Acknowledgement(title: "Banana", license: "License 3")
        ]

        let sorted = acks.sorted()

        // Case-sensitive: uppercase comes before lowercase in ASCII
        XCTAssertEqual(sorted[0].title, "Banana")
        XCTAssertEqual(sorted[1].title, "Zebra")
        XCTAssertEqual(sorted[2].title, "apple")
    }

    func testCodingKeys() {
        let ack = Acknowledgement(title: "TestPackage", license: "MIT License")
        let encoder = PropertyListEncoder()
        encoder.outputFormat = .xml

        XCTAssertNoThrow(try encoder.encode(ack))

        let data = try! encoder.encode(ack)
        let plistString = String(data: data, encoding: .utf8)!

        // Verify the coding keys are correct (Title, FooterText, Type)
        XCTAssertTrue(plistString.contains("<key>Title</key>"))
        XCTAssertTrue(plistString.contains("<key>FooterText</key>"))
        XCTAssertTrue(plistString.contains("<key>Type</key>"))
        XCTAssertTrue(plistString.contains("<string>PSGroupSpecifier</string>"))
    }

    func testEncodingAndDecoding() throws {
        let original = Acknowledgement(title: "SwiftUI", license: "Apache 2.0")
        let encoder = PropertyListEncoder()
        let data = try encoder.encode(original)

        let decoder = PropertyListDecoder()
        let decoded = try decoder.decode(Acknowledgement.self, from: data)

        XCTAssertEqual(decoded.title, original.title)
        XCTAssertEqual(decoded.license, original.license)
        XCTAssertEqual(decoded.type, original.type)
    }

    func testArrayEncoding() throws {
        let acks = [
            Acknowledgement(title: "Package1", license: "MIT"),
            Acknowledgement(title: "Package2", license: "Apache")
        ]

        let encoder = PropertyListEncoder()
        encoder.outputFormat = .xml
        let data = try encoder.encode(acks)

        let decoder = PropertyListDecoder()
        let decoded = try decoder.decode([Acknowledgement].self, from: data)

        XCTAssertEqual(decoded.count, 2)
        XCTAssertEqual(decoded[0].title, "Package1")
        XCTAssertEqual(decoded[1].title, "Package2")
    }
}
