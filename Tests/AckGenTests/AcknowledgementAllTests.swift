//
//  AcknowledgementAllTests.swift
//  AckGenTests
//
//  Created by Martin Pfundmair on 2026-01-13.
//

import XCTest
@testable import AckGenCore

final class AcknowledgementAllTests: XCTestCase {

    /// Helper to load acknowledgements from the Fixtures subdirectory
    private func loadAcknowledgementsFromFixture(plistName: String) -> [Acknowledgement] {
        return Acknowledgement.all(fromPlist: "Fixtures/\(plistName)", in: Bundle.module)
    }

    func testAllDecodesFixturePlist() {
        // Given: A fixture plist in the test bundle's Fixtures directory
        // When: Loading acknowledgements from the fixture
        let acks = loadAcknowledgementsFromFixture(plistName: "Acknowledgements")

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
        let acks = loadAcknowledgementsFromFixture(plistName: "Acknowledgements")

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
        // Given: An invalid plist file (the invalid-utf8-license fixture)
        // Note: This test verifies graceful handling of invalid data
        // The all() method should return empty array for any decode failure

        // When: Attempting to decode a plist with invalid UTF-8 content
        let acks = loadAcknowledgementsFromFixture(plistName: "invalid-utf8-license")

        // Then: Should return empty array instead of crashing
        XCTAssertTrue(acks.isEmpty)
    }
}
