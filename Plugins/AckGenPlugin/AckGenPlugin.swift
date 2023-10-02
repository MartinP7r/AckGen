//
//  AckGenPlugin.swift
//
//
//  Created by Žan Menard on 10/08/2023.
//

import Foundation
import PackagePlugin

@main struct AckGenPlugin: BuildToolPlugin {
  func createBuildCommands(
    context: PluginContext,
    target: Target
  ) async throws -> [Command] {
    var tempPath = context.pluginWorkDirectory
    while tempPath.lastComponent != "SourcePackages" {
      tempPath = tempPath.removingLastComponent()
      guard tempPath.lastComponent != "/" else { return [] }
    }
    tempPath = tempPath.removingLastComponent()

    return [
      .prebuildCommand(
        displayName: "AckGen",
        executable: try context.tool(named: "AckGenCLIBinary").path,
        arguments: [],
        environment: [
          "SRCROOT": target.directory,
          "PROJECT_TEMP_DIR": tempPath,
        ],
        outputFilesDirectory: context.pluginWorkDirectory
      )
    ]
  }
}
