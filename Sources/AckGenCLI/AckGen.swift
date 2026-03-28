//
//  AckGen.swift
//
//
//  Created by Martin Pfundmair on 2021-08-09.
//

import AckGenCore
import ArgumentParser
import Foundation

/// Derives the SPM `SourcePackages/checkouts` path from Xcode's `PROJECT_TEMP_DIR`.
///
/// Uses the last occurrence of `/Build/` to handle edge cases where "Build"
/// appears earlier in the path (e.g., in a username or directory name).
/// - Parameter tempDirPath: The value of the `PROJECT_TEMP_DIR` environment variable.
/// - Returns: The path to the `SourcePackages/checkouts` directory.
func deriveCheckoutsPath(from tempDirPath: String) -> String {
    if let range = tempDirPath.range(of: "/Build/", options: .backwards) {
        return String(tempDirPath[..<range.lowerBound]) + "/SourcePackages/checkouts"
    } else {
        return tempDirPath.components(separatedBy: "/Build/")[0] + "/SourcePackages/checkouts"
    }
}

struct LicenseScanner {
    struct ScanResult {
        var acknowledgements: [Acknowledgement]
        var skippedFiles: [(package: String, file: String, reason: String)]
    }

    static let licenseFiles = ["LICENSE", "LICENSE.txt", "LICENSE.md"]

    static func scan(checkoutsPath: String, fileManager: FileManager = .default) throws -> ScanResult {
        let packageDirectories = try fileManager.contentsOfDirectory(atPath: checkoutsPath)
        var result = ScanResult(acknowledgements: [], skippedFiles: [])

        for pkgDir in packageDirectories where pkgDir.prefix(1) != "." {
            for file in licenseFiles {
                guard let data = fileManager.contents(atPath: "\(checkoutsPath)/\(pkgDir)/\(file)") else { continue }
                guard let license = String(data: data, encoding: .utf8) else {
                    result.skippedFiles.append((package: pkgDir, file: file, reason: "invalid UTF-8 encoding"))
                    continue
                }
                result.acknowledgements.append(Acknowledgement(title: pkgDir, license: license))
                break // Found license for this package, move to next
            }
        }

        return result
    }
}

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

        guard let srcRoot = ProcessInfo.processInfo.environment["SRCROOT"] else {
            throw ValidationError("Could not detect the source root directory (SRCROOT environment variable not set)")
        }
        guard let tempDirPath = ProcessInfo.processInfo.environment["PROJECT_TEMP_DIR"] else {
            throw ValidationError("Could not detect the project's temp directory (PROJECT_TEMP_DIR environment variable not set)")
        }

        let plistPath: String = output ?? "\(srcRoot)/Acknowledgements.plist"
        let packageCachePath = deriveCheckoutsPath(from: tempDirPath)

        let result = try LicenseScanner.scan(checkoutsPath: packageCachePath)

        printSkippedFilesSummary(result.skippedFiles)

        if result.acknowledgements.isEmpty {
            throw ValidationError(
                "No license files found in \(packageCachePath). " +
                "Ensure SPM packages are resolved (Xcode → File → Packages → Resolve)."
            )
        }

        let encoder = PropertyListEncoder()
        encoder.outputFormat = .xml

        if settings {
            let acknowledgementsSettings = AcknowledgementsStringsTable(name: title, acknowledgements: result.acknowledgements)
            let data = try encoder.encode(acknowledgementsSettings)
            try data.write(to: URL(fileURLWithPath: plistPath))
        } else {
            let data = try encoder.encode(result.acknowledgements)
            try data.write(to: URL(fileURLWithPath: plistPath))
        }

        print("✓ Generated \(result.acknowledgements.count) acknowledgement(s) at: \(plistPath)")
    }

    private func printSkippedFilesSummary(_ skippedFiles: [(package: String, file: String, reason: String)]) {
        guard !skippedFiles.isEmpty else { return }
        print("warning: Skipped \(skippedFiles.count) file(s) due to encoding issues")
        #if DEV
        for skip in skippedFiles {
            print("  - \(skip.package)/\(skip.file): \(skip.reason)")
        }
        #endif
    }
}
