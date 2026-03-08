//
//  Acknowledgement.swift
//  AckGen
//
//  Created by Martin Pfundmair on 2021-08-09.
//

import Foundation

public struct Acknowledgement: Codable {
    
    public let title: String
    public let license: String
    public let type: String = "PSGroupSpecifier"

    enum CodingKeys: String, CodingKey {
        case title = "Title"
        case license = "FooterText"
        case type = "Type"
    }

    public init(title: String, license: String) {
        self.title = title
        self.license = license
    }

    /// Fetch all the acknowledgements from the acknowledgement property list's file.
    /// - Parameters:
    ///   - plistName: the property list's filename without extension. Defaults to `Acknowledgements`.
    ///   - bundle: the bundle where the plist file is located. Defaults to the main bundle.
    /// - Returns: Array of objects containing title and licence.
    public static func all(
        fromPlist plistName: String = "Acknowledgements",
        in bundle: Bundle = .main
    ) -> [Acknowledgement] {
        guard let path = bundle.path(forResource: plistName, ofType: "plist"),
              let xml = FileManager.default.contents(atPath: path),
              let acks = try? PropertyListDecoder().decode([Acknowledgement].self, from: xml) else { return [] }
        return acks.sorted()
    }
}

extension Acknowledgement: Comparable {
    public static func < (lhs: Acknowledgement, rhs: Acknowledgement) -> Bool {
        lhs.title.localizedStandardCompare(rhs.title) == .orderedAscending
    }
}
