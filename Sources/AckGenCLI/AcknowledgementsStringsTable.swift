//
//  Acknowledgement.swift
//  AckGen
//
//  Created by Martin Pfundmair on 2021-08-09.
//

import AckGenCore
import Foundation

public struct AcknowledgementsStringsTable: Codable {
    
    public let name: String
    public let acknowledgements: [Acknowledgement]

    enum CodingKeys: String, CodingKey {
        case name = "StringsTable", acknowledgements = "PreferenceSpecifiers"
    }

    public init(name: String, acknowledgements: [Acknowledgement]) {
        self.name = name
        self.acknowledgements = acknowledgements
    }

    /// Loads acknowledgements from a property list file, decodes them, and returns a sorted array of acknowledgements.
    /// - Parameter plistName: The name of the property list file (without the `.plist` extension) to load acknowledgements from.
    /// - Returns: An array of `Acknowledgement` objects sorted alphabetically by their title. Returns an empty array if the file cannot be loaded or decoded.
    public static func all(fromPlist plistName: String = "Acknowledgements") -> [Acknowledgement] {
        guard let path = Bundle.main.path(forResource: plistName, ofType: "plist"),
              let xml = FileManager.default.contents(atPath: path),
              let acks = try? PropertyListDecoder().decode(AcknowledgementsStringsTable.self, from: xml) else { return [] }
        return acks.acknowledgements.sorted(by: { $0.title.lowercased() < $1.title.lowercased() })
    }
}
