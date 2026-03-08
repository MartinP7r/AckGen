//
//  AckGen.swift
//
//
//  Created by Martin Pfundmair on 2021-08-09.
//

import AckGenCore
import ArgumentParser
import Foundation

@main
struct AckGen: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Generate acknowledgements plist from Swift Package Manager dependencies",
        version: "0.8.0"
    )

    @Option(name: .shortAndLong, help: "Output path for the generated plist file")
    var output: String?

    @Flag(name: .long, help: "Generate Settings.bundle format")
    var settings: Bool = false

    @Option(name: .long, help: "Title for Settings.bundle (only used with --settings)")
    var title: String = "Acknowledgements"

    func run() throws {
        print("Generating Acknowledgements file")

        let licenseFiles: [String] = ["LICENSE", "LICENSE.txt", "LICENSE.md"]

        guard let srcRoot = ProcessInfo.processInfo.environment["SRCROOT"] else {
            throw ValidationError("Could not detect the source root directory (SRCROOT environment variable not set)")
        }
        guard let tempDirPath = ProcessInfo.processInfo.environment["PROJECT_TEMP_DIR"] else {
            throw ValidationError("Could not detect the project's temp directory (PROJECT_TEMP_DIR environment variable not set)")
        }

        let plistPath: String = output ?? "\(srcRoot)/Acknowledgements.plist"

        let packageCachePath = tempDirPath.components(separatedBy: "/Build/")[0] + "/SourcePackages/checkouts"
        let fman = FileManager.default

        let packageDirectories = try fman.contentsOfDirectory(atPath: packageCachePath)
        var acknowledgements = [Acknowledgement]()

        for pkgDir in packageDirectories where pkgDir.prefix(1) != "." {
            for file in licenseFiles {
                guard let data = fman.contents(atPath: "\(packageCachePath)/\(pkgDir)/\(file)") else { continue }
                guard let license = String(data: data, encoding: .utf8) else {
                    print("warning: Skipping \(pkgDir)/\(file) - invalid UTF-8 encoding")
                    continue
                }
                let new = Acknowledgement(title: pkgDir, license: license)
                acknowledgements.append(new)
                break
            }
        }

        if acknowledgements.isEmpty {
            throw ValidationError(
                "No license files found in \(packageCachePath). " +
                "Ensure SPM packages are resolved (Xcode → File → Packages → Resolve)."
            )
        }

        let encoder = PropertyListEncoder()
        encoder.outputFormat = .xml

        if settings {
            let acknowledgementsSettings = AcknowledgementsStringsTable(name: title, acknowledgements: acknowledgements)
            let data = try encoder.encode(acknowledgementsSettings)
            try data.write(to: URL(fileURLWithPath: plistPath))
        } else {
            let data = try encoder.encode(acknowledgements)
            try data.write(to: URL(fileURLWithPath: plistPath))
        }

        print("✓ Generated acknowledgements at: \(plistPath)")
    }
}
