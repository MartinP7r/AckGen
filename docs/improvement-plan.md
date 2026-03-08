# AckGen Improvement Plan

## Overview

Fix bugs, improve CLI ergonomics, and establish a working test suite.

## Changes

### 1. Fix Force Unwrap Crash (Bug)

**File:** `Sources/AckGenCLI/AckGen.swift:46`

```swift
// Before
let new = Acknowledgement(title: pkgDir, license: String(data: data, encoding: .utf8)!)

// After
guard let license = String(data: data, encoding: .utf8) else { continue }
let new = Acknowledgement(title: pkgDir, license: license)
```

---

### 2. Add Exit Codes (Bug)

**File:** `Sources/AckGenCLI/AckGen.swift`

Replace `return` after error prints with proper exit:
```swift
import Darwin

// After each error print:
Darwin.exit(1)
```

Or better: refactor to throw errors and handle at top level.

---

### 3. Migrate to SwiftArgumentParser

**File:** `Package.swift`
- Add dependency: `swift-argument-parser` from 1.3.0

**File:** `Sources/AckGenCLI/AckGen.swift`
- Convert to `@main struct AckGen: ParsableCommand`
- Define arguments:
  - `--output` / `-o`: Output plist path (default: `$SRCROOT/Acknowledgements.plist`)
  - `--settings`: Flag for Settings.bundle format
  - `--title`: Settings bundle title (default: "Acknowledgements")
  - `--version`: Auto-generated

**File:** `Sources/AckGenCLI/main.swift`
- Remove (SwiftArgumentParser uses `@main`)

**Breaking change:** Positional args → named flags. Update README and Example scripts.

---

### 4. Set Up Unit Tests

**File:** `Tests/AckGenTests/AckGenTests.swift`
- Delete broken integration test

**New file:** `Tests/AckGenTests/AcknowledgementTests.swift`
```swift
import XCTest
@testable import AckGenCore

final class AcknowledgementTests: XCTestCase {

    func testDecodeFromPlist() throws {
        // Test Acknowledgement.all() with fixture plist
    }

    func testSortingIsCaseInsensitive() {
        let acks = [
            Acknowledgement(title: "Zebra", license: ""),
            Acknowledgement(title: "apple", license: ""),
            Acknowledgement(title: "Banana", license: "")
        ]
        let sorted = acks.sorted()
        XCTAssertEqual(sorted.map(\.title), ["apple", "Banana", "Zebra"])
    }

    func testComparable() {
        let a = Acknowledgement(title: "A", license: "")
        let b = Acknowledgement(title: "B", license: "")
        XCTAssertTrue(a < b)
    }
}
```

**New file:** `Tests/AckGenTests/Fixtures/TestAcknowledgements.plist`
- Sample plist for decode testing

**Update:** `Package.swift` - add resources to test target if needed

---

### 5. Remove Hardcoded `type` from Core Model (Optional)

**File:** `Sources/AckGenCore/Acknowledgement.swift`
- Remove `type` property (only needed for Settings.bundle format)

**File:** `Sources/AckGenCLI/AcknowledgementsStringsTable.swift`
- Add wrapper that includes `type` during encoding

*Note: This is a breaking change for anyone manually encoding Acknowledgement. Consider for v1.0.*

---

## Execution Order

1. Fix force unwrap (2 min) - immediate safety
2. Add exit codes (5 min) - immediate correctness
3. Set up unit tests (15 min) - establish test infrastructure
4. Migrate to SwiftArgumentParser (20 min) - larger refactor, needs tests passing first
5. (Optional) Clean up type property - defer to v1.0

## Files to Modify

| File | Change |
|------|--------|
| `Package.swift` | Add swift-argument-parser dependency |
| `Sources/AckGenCLI/AckGen.swift` | Fix crash, add exit codes, migrate to ArgumentParser |
| `Sources/AckGenCLI/main.swift` | Delete |
| `Tests/AckGenTests/AckGenTests.swift` | Replace with proper unit tests |
| `Example/ackgen.sh` | Update CLI invocation |
| `Example/ackgen_settings.sh` | Update CLI invocation |
| `README.md` | Update CLI usage examples |

## Verification

```bash
# After each change
swift build
swift test

# After ArgumentParser migration
swift run ackgen --help
swift run ackgen --version
```
