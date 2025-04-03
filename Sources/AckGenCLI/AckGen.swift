//
//  AckGen.swift
//  
//
//  Created by Martin Pfundmair on 2021-08-09.
//

import AckGenCore
import Foundation

struct AckGenCLI {

    static func main() {
        print("Generating Acknowledgements file")

        let licenseFiles: [String] = ["LICENSE", "LICENSE.txt", "LICENSE.md"]
        
        let arguments: [String] = Array(CommandLine.arguments.dropFirst())

        guard let srcRoot = ProcessInfo.processInfo.environment["SRCROOT"] else {
            print("error: could not detect the source root directory.")
            return
        }
        guard let tempDirPath = ProcessInfo.processInfo.environment["PROJECT_TEMP_DIR"] else {
            print("error: could not detect the project's temp directory.")
            return
        }

        let plistPath: String = arguments.first ?? "\(srcRoot)/Acknowledgements.plist"

        let packageCachePath = tempDirPath.components(separatedBy: "/Build/")[0] + "/SourcePackages/checkouts"
        let fman = FileManager.default

        do {

            let packageDirectories = try fman.contentsOfDirectory(atPath: packageCachePath)
            var acknowledgements = [Acknowledgement]()

            for pkgDir in packageDirectories where pkgDir.prefix(1) != "." {
                for file in licenseFiles {
                    guard let data = fman.contents(atPath: "\(packageCachePath)/\(pkgDir)/\(file)")  else { continue }
                    let new = Acknowledgement(title: pkgDir, license: String(data: data, encoding: .utf8)!)
                    acknowledgements.append(new)
                }
            }

            let encoder = PropertyListEncoder()
            encoder.outputFormat = .xml

            let data = try encoder.encode(acknowledgements)
            try data.write(to: URL(fileURLWithPath: plistPath))
        } catch {
            print(error)
        }
    }
}
