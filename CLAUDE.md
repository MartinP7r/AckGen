# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

AckGen is an **Ack**nowledgements **Gen**erator that automatically extracts license information from Swift Package Manager dependencies and generates plist files for iOS/macOS apps. Current version: **0.8.0**.

- Swift tools version: 5.9
- Platforms: macOS 10.15+, iOS 13+, watchOS 6+, tvOS 14+
- Single external dependency: `swift-argument-parser` (1.3.0+)

## Build & Test Commands

```bash
swift build                # Build the CLI executable
swift build -c release     # Build in release mode
swift test                 # Run all tests

# Run the CLI (requires Xcode env vars SRCROOT, PROJECT_TEMP_DIR)
swift run ackgen --output <output_path> --settings --title <settingsTitle>

# Bootstrap example project (requires mint)
make bootstrap

# Open example project in Xcode
make open
```

## CI

GitHub Actions runs `swift build` + `swift test` on `macos-latest` for pushes and PRs to `main`. See `.github/workflows/unit-tests.yml`.

## Architecture

Three-module Swift Package:

```
AckGenCore (library)
├── Acknowledgement.swift    # Model + plist decoding for runtime use

AckGenCLI (executable: ackgen)
├── AckGen.swift             # Main entry point (@main ParsableCommand) + LicenseScanner
├── AcknowledgementsStringsTable.swift  # Settings.bundle plist format
├── EnvironmentKey.swift     # Xcode environment variable name constants (currently unused)

AckGenUI (library)
├── AcknowledgementsList.swift   # SwiftUI list view for displaying licenses
├── CustomNavigationTitle.swift  # Navigation title helper
```

**Data Flow:**
1. CLI runs as Xcode build phase, reads `PROJECT_TEMP_DIR` to find SPM checkouts
2. Finds the `SourcePackages/checkouts` directory by locating the last `/Build/` segment in the temp path (handles edge cases like "Build" in directory names)
3. `LicenseScanner.scan()` finds LICENSE, LICENSE.txt, LICENSE.md per package (first match wins, prevents duplicates); tracks skipped files with reasons
4. Encodes to plist (standard array or Settings.bundle format)
5. App uses `Acknowledgement.all()` to decode plist at runtime

**Build Configuration:**
- `DEV` compiler flag is set in debug builds via `swiftSettings` — enables verbose skipped-file diagnostics

**Two Output Formats:**
- Standard: Array of `Acknowledgement` (default)
- Settings Bundle: `AcknowledgementsStringsTable` format with `StringsTable` and `PreferenceSpecifiers` keys

## Testing

Tests are in `Tests/AckGenTests/` with fixtures in `Tests/AckGenTests/Fixtures/`:

- `AcknowledgementTests.swift` — Model encoding/decoding, sorting behavior
- `AckGenTests.swift` — CLI integration tests (Settings.bundle format)
- `AcknowledgementAllTests.swift` — `Acknowledgement.all()` runtime loading
- `DuplicateLicenseFileTests.swift` — Ensures only one license per package
- `LicenseScannerTests.swift` — File discovery, LICENSE variants, hidden dirs, duplicate prevention, invalid UTF-8 tracking

Fixtures: `Acknowledgements.plist`, `invalid-utf8-license.plist`

## Coding Conventions

- Avoid force unwraps; prefer proper error handling
- New public API should have documentation comments
- Acknowledgements are sorted case-insensitively using locale-aware comparison
- Both `AckGenCore` and `AckGenUI` include `PrivacyInfo.xcprivacy` resources

## Example App

Located in `Example/`. Uses XcodeGen (`project.yml`) for project generation. Contains pre-build scripts demonstrating both plist formats:
- `ackgen.sh` — Standard format
- `ackgen_settings.sh` — Settings.bundle format
