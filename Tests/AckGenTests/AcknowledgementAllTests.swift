//
//  AcknowledgementAllTests.swift
//  AckGenTests
//
//  Created by Martin Pfundmair on 2026-01-13.
//

import XCTest
@testable import AckGenCore

final class AcknowledgementAllTests: XCTestCase {

    func testAllDecodesFixturePlist() {
        // Given: A fixture plist in the test bundle's Fixtures directory
        // When: Loading acknowledgements from the fixture
        let acks = Acknowledgement.all(fromPlist: "Fixtures/Acknowledgements", in: Bundle.module)

        // Then: All entries should be decoded correctly
        XCTAssertEqual(acks.count, 3)

        // Verify the content is decoded properly
        let titles = acks.map(\.title)
        XCTAssertTrue(titles.contains("Zebra"))
        XCTAssertTrue(titles.contains("apple"))
        XCTAssertTrue(titles.contains("Banana"))

        // Verify license content is present
        let zebra = acks.first { $0.title == "Zebra" }
        XCTAssertEqual(zebra?.license, "MIT License for Zebra package")
    }

    func testAllSortsCaseInsensitively() {
        // Given: A fixture plist with mixed case titles (Zebra, apple, Banana)
        // When: Loading acknowledgements (which applies case-insensitive sorting)
        let acks = Acknowledgement.all(fromPlist: "Fixtures/Acknowledgements", in: Bundle.module)

        // Then: Should be sorted case-insensitively: apple, Banana, Zebra
        XCTAssertEqual(acks.count, 3)
        XCTAssertEqual(acks[0].title, "apple")   // 'a' comes first
        XCTAssertEqual(acks[1].title, "Banana")  // 'B' (as 'b') comes second
        XCTAssertEqual(acks[2].title, "Zebra")   // 'Z' (as 'z') comes last
    }

    func testAllReturnsEmptyArrayForMissingPlist() {
        // Given: A non-existent plist name
        let bundle = Bundle.module

        // When: Loading from a non-existent plist
        let acks = Acknowledgement.all(fromPlist: "NonExistent", in: bundle)

        // Then: Should return empty array instead of crashing
        XCTAssertTrue(acks.isEmpty)
    }

    func testAllReturnsEmptyArrayForInvalidPlist() {
        // Given: A malformed/invalid plist file (fixture: invalid-utf8-license)
        // Note: This test verifies graceful handling of decode failures for malformed plist data
        // The all() method should return an empty array for any plist decode failure

        // When: Attempting to decode a malformed plist that cannot be parsed
        let acks = Acknowledgement.all(fromPlist: "Fixtures/invalid-utf8-license", in: Bundle.module)

        // Then: Should return empty array instead of crashing
        XCTAssertTrue(acks.isEmpty)
    }
}
