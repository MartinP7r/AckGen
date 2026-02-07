# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

AckGen is an **Ack**nowledgements **Gen**erator that automatically extracts license information from Swift Package Manager dependencies and generates plist files for iOS/macOS apps.

## Build Commands

```bash
# Build the CLI executable
swift build

# Build in release mode
swift build -c release

# Run the CLI (requires Xcode environment variables SRCROOT, PROJECT_TEMP_DIR)
swift run ackgen --output <output_path> --settings <forSettings> --title <settingsTitle>

# Run tests
swift test

# Bootstrap example project (requires mint)
make bootstrap

# Open example project in Xcode
make open
```

## Architecture

Three-module Swift Package with no external dependencies:

```
AckGenCore (library)
├── Acknowledgement.swift    # Model + plist decoding for runtime use
│
AckGenCLI (executable: ackgen)
├── AckGen.swift             # Main logic: scans SourcePackages/checkouts for LICENSE files
├── AcknowledgementsStringsTable.swift  # Settings.bundle plist format
│
AckGenUI (library)
├── AcknowledgementsList.swift   # SwiftUI list view for displaying licenses
```

**Data Flow:**
1. CLI runs as Xcode build phase, reads `PROJECT_TEMP_DIR` to find SPM checkouts
2. Scans for LICENSE, LICENSE.txt, LICENSE.md in each package directory
3. Encodes to plist (standard array or Settings.bundle format)
4. App uses `Acknowledgement.all()` to decode plist at runtime

**Two Output Formats:**
- Standard: Array of `Acknowledgement` (default)
- Settings Bundle: `AcknowledgementsStringsTable` format with `StringsTable` and `PreferenceSpecifiers` keys

## Example App

Located in `Example/`. Uses XcodeGen (`project.yml`) for project generation. Contains pre-build scripts demonstrating both plist formats:
- `ackgen.sh` - Standard format
- `ackgen_settings.sh` - Settings.bundle format
