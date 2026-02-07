#!/usr/bin/env swift

import Foundation

/// Diagnostic tool for AckGen path detection issues
struct PathDiagnostics {
    
    static func main() {
        print("🔍 AckGen Path Diagnostics")
        print("==========================")
        print("")
        
        // Check if we're running in an Xcode environment
        guard let projectTempDir = ProcessInfo.processInfo.environment["PROJECT_TEMP_DIR"] else {
            print("❌ ERROR: PROJECT_TEMP_DIR is not set")
            print("This script must be run from an Xcode Run Script phase or with PROJECT_TEMP_DIR set")
            print("")
            print("To test manually, set PROJECT_TEMP_DIR to your Xcode build directory, e.g.:")
            print("export PROJECT_TEMP_DIR=/Users/$USER/Library/Developer/Xcode/DerivedData/YourApp-xyz/Build/Intermediates.noindex/YourApp.build")
            exit(1)
        }
        
        let srcRoot = ProcessInfo.processInfo.environment["SRCROOT"]
        
        print("📂 Environment Variables:")
        print("  PROJECT_TEMP_DIR: \(projectTempDir)")
        print("  SRCROOT: \(srcRoot ?? "not set")")
        print("")
        
        // Calculate package path using improved logic (handles edge cases like "Build" in username)
        // Find the last occurrence of "/Build/" and take everything before it
        let calculatedBase: String
        if let range = projectTempDir.range(of: "/Build/", options: .backwards) {
            calculatedBase = String(projectTempDir[..<range.lowerBound])
        } else {
            // Fallback to old logic if pattern not found
            calculatedBase = projectTempDir.components(separatedBy: "/Build/")[0]
        }
        let calculatedPackagePath = "\(calculatedBase)/SourcePackages/checkouts"
        
        print("🧮 Path Calculation:")
        print("  Base directory: \(calculatedBase)")
        print("  Package path: \(calculatedPackagePath)")
        print("")
        
        // Check using relative path approach (from old README)
        let relativeBase = URL(fileURLWithPath: projectTempDir)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .path
        let relativePackagePath = "\(relativeBase)/SourcePackages/checkouts"
        
        print("📍 Relative Path Approach (from old README):")
        print("  Relative base: \(relativeBase)")
        print("  Package path: \(relativePackagePath)")
        print("")
        
        let fileManager = FileManager.default
        
        // Verify both approaches
        print("✅ Verification:")
        var foundPackages: [String] = []
        var calculatedPathExists = false
        
        if fileManager.fileExists(atPath: calculatedPackagePath) {
            print("  ✓ Calculated path exists: \(calculatedPackagePath)")
            calculatedPathExists = true
            
            if let packages = try? fileManager.contentsOfDirectory(atPath: calculatedPackagePath) {
                let nonHidden = packages.filter { !$0.hasPrefix(".") }
                if !nonHidden.isEmpty {
                    print("  ✓ Found packages:")
                    nonHidden.forEach { print("    - \($0)") }
                    foundPackages = nonHidden
                } else {
                    print("  ⚠ No packages found in \(calculatedPackagePath)")
                }
            }
        } else {
            print("  ✗ Calculated path does not exist: \(calculatedPackagePath)")
        }
        
        if fileManager.fileExists(atPath: relativePackagePath) {
            print("  ✓ Relative path exists: \(relativePackagePath)")
        } else {
            print("  ✗ Relative path does not exist: \(relativePackagePath)")
        }
        
        // Check for AckGen specifically
        let ackgenCalculated = "\(calculatedPackagePath)/AckGen"
        let ackgenRelative = "\(relativePackagePath)/AckGen"
        
        print("")
        print("🔎 AckGen Package Location:")
        
        var ackgenFound = false
        
        if fileManager.fileExists(atPath: ackgenCalculated) {
            print("  ✓ Found via calculated path: \(ackgenCalculated)")
            ackgenFound = true
        } else if fileManager.fileExists(atPath: ackgenRelative) {
            print("  ✓ Found via relative path: \(ackgenRelative)")
            ackgenFound = true
        } else {
            print("  ✗ AckGen package not found in either location")
            print("")
            print("💡 Troubleshooting:")
            print("  1. Make sure AckGen is added as a Swift Package dependency in Xcode")
            print("  2. Build your project at least once so SPM downloads dependencies")
            print("  3. Check if packages are in a different location:")
            print("     find ~/Library/Developer/Xcode/DerivedData -name AckGen -type d 2>/dev/null")
        }
        
        print("")
        print("📋 Summary:")
        
        if ackgenFound {
            print("  ✅ AckGen package is accessible")
            print("")
            print("Use this in your Run Script:")
            print("┌─────────────────────────────────────────────────────────────")
            print("│ # Calculate the package path dynamically")
            print("│ BASE_DIR=$(echo \"$PROJECT_TEMP_DIR\" | awk -F'/Build/' '{print $1}')")
            print("│ DIR=\"$BASE_DIR/SourcePackages/checkouts/AckGen\"")
            print("│ ")
            print("│ if [ -d \"$DIR\" ]; then")
            print("│   cd \"$DIR\"")
            print("│   SDKROOT=$(xcrun --sdk macosx --show-sdk-path)")
            print("│   swift run ackgen")
            print("│ else")
            print("│   echo \"warning: AckGen not found at $DIR\"")
            print("│ fi")
            print("└─────────────────────────────────────────────────────────────")
        } else {
            print("  ❌ AckGen package could not be found")
            print("  Please verify that AckGen is installed via Swift Package Manager")
        }
        
        print("")
        
        // Additional diagnostics
        if calculatedPathExists && !foundPackages.contains("AckGen") {
            print("⚠️  Note: Package directory exists but AckGen is not found.")
            print("Found packages: \(foundPackages.joined(separator: ", "))")
            print("Make sure AckGen is listed in your Xcode project's Swift Packages.")
        }
    }
}

PathDiagnostics.main()
