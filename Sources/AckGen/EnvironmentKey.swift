//
//  File.swift
//  
//
//  Created by Martin Pfundmair on 2021-08-09.
//

import Foundation
enum EnvironmentKey {
  static let bundleIdentifier = "PRODUCT_BUNDLE_IDENTIFIER"
  static let productModuleName = "PRODUCT_MODULE_NAME"
  static let scriptInputFileCount = "SCRIPT_INPUT_FILE_COUNT"
  static let scriptOutputFileCount = "SCRIPT_OUTPUT_FILE_COUNT"
  static let target = "TARGET_NAME"
  static let tempDir = "TEMP_DIR"
  static let xcodeproj = "PROJECT_FILE_PATH"
  static let infoPlistFile = "INFOPLIST_FILE"
  static let codeSignEntitlements = "CODE_SIGN_ENTITLEMENTS"

  static func scriptInputFile(number: Int) -> String {
    return "SCRIPT_INPUT_FILE_\(number)"
  }

  static func scriptOutputFile(number: Int) -> String {
    return "SCRIPT_OUTPUT_FILE_\(number)"
  }
}
