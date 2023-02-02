//
//  Acknowledgement.swift
//  AckGen
//
//  Created by Martin Pfundmair on 2021-08-09.
//

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


    /// <#Description#>
    /// - Parameter plistName: the property list's filename without extension
    /// - Returns: Array of objects containing title and
    public static func all(fromPlist plistName: String = "Acknowledgements") -> [Acknowledgement] {
        guard let path = Bundle.main.path(forResource: plistName, ofType: "plist"),
              let xml = FileManager.default.contents(atPath: path),
              let acks = try? PropertyListDecoder().decode([AcknowledgementsStringsTable].self, from: xml) else { return [] }
        return acks.acknowledgements.sorted(by: { $0.title.lowercased() < $1.title.lowercased() })
    }
}
