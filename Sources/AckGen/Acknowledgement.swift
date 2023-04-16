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

    public init(title: String, license: String) {
        self.title = title
        self.license = license
    }


    /// <#Description#>
    /// - Parameter plistName: the property list's filename without extension
    /// - Returns: Array of objects containing title and
    public static func all(fromPlist plistName: String = "Acknowledgements") -> [Acknowledgement] {
        guard let path = Bundle.main.path(forResource: plistName, ofType: "plist"),
              let xml = FileManager.default.contents(atPath: path),
              let acks = try? PropertyListDecoder().decode([Acknowledgement].self, from: xml) else { return [] }
        return acks.sorted(by: { $0.title.lowercased() < $1.title.lowercased() })
    }
}

extension Acknowledgement: Comparable {
    public static func < (lhs: Acknowledgement, rhs: Acknowledgement) -> Bool {
        lhs.title < rhs.title
    }
}
