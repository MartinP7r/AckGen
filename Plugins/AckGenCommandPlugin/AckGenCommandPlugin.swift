//
//  AckGenPlugin.swift
//  
//
//  Created by Matic Vrenko on 01/10/2023.
//

import Foundation
import PackagePlugin

@main struct AckGenCommandPlugin: CommandPlugin {
  func performCommand(context: PackagePlugin.PluginContext, arguments: [String]) async throws {
    // We'll be invoking `sometool` to format code, so start by locating it.
    let ackGen = try context.tool(named: "AckGenCLIBinary")

    // Extract the target arguments (if there are none, we assume all).
    var argExtractor = ArgumentExtractor(arguments)
    let targetNames = argExtractor.extractOption(named: "target")
    let targets = try context.package.targets(named: targetNames)

    print(context.pluginWorkDirectory)

    var tempPath = context.pluginWorkDirectory
    try FileManager().createDirectory(at: URL(filePath: "\(tempPath.string)/SourcePackages/checkouts"), withIntermediateDirectories: true, attributes: nil)

    print(targets.map({$0.name}))

    // Iterate over the targets we've been asked to format.
    for target in targets {
      // Invoke `AckGen` on the target directory
      let process = Process()
      process.environment = [
        "SRCROOT": target.directory.string,
        "PROJECT_TEMP_DIR": tempPath.string
      ]

      process.executableURL = URL(fileURLWithPath: ackGen.path.string)
      try process.run()
      process.waitUntilExit()

      // Check whether the subprocess invocation was successful.
      if process.terminationReason == .exit && process.terminationStatus == 0 {
        print("Added documentation to \(target.directory).")
      }
      else {
        let problem = "\(process.terminationReason):\(process.terminationStatus)"
        Diagnostics.error("Formatting invocation failed: \(problem)")
      }
    }
  }
}
