# AckGen

Simple **Ack**nowledgements **Gen**erator for SPM package license information.

## Overview

AckGen automatically generates a `plist` file containing the title and license information for all Swift packages used in your project.  
This can be used to feed a SwiftUI List or UITableView dataSource in your app.

|                            |                         |
| -------------------------- | ----------------------- |
| ![](docs/sample_plist.png) | ![](docs/ui_sample.gif) |

## Requirements

- Xcode 12+ (tested with 12.5)

## Installation

1. Add AckGen as a dependency for your project in Xcode.  

> **Warning**
> Leave the checkbox for executable unchecked

2. Add the following as a Run Script for your target in Xcode

```sh
# Calculate the package path dynamically (works with various Xcode configurations)
# Use parameter expansion to remove everything from /Build/ onwards
BASE_DIR="${PROJECT_TEMP_DIR%/Build/*}"
DIR="$BASE_DIR/SourcePackages/checkouts/AckGen"

if [ -d "$DIR" ]; then
  cd "$DIR"
  SDKROOT=$(xcrun --sdk macosx --show-sdk-path)
  swift run ackgen
else
  echo "warning: AckGen not found. Please install the package via SPM (https://github.com/MartinP7r/AckGen#installation)"
fi
```

> **Note**
> The script dynamically calculates the package path from `PROJECT_TEMP_DIR` to support various Xcode project configurations. If you encounter issues, run `./diagnose_path.sh` from this repository to debug your setup.

Make sure to set `ENABLE_USER_SCRIPT_SANDBOXING` to `NO` in your build settings so the build phase above can write to the desired destination.

If you want the plist file to be saved somewhere other than `Acknowledgements.plist` at the root of your project (`$SRCROOT/Acknowledgements.plist`), you can provide a custom path as the first command line argument to `ackgen` above. 

```sh
  swift run ackgen $SRCROOT/PackageLicenses.plist
```

3. Add the generated `plist` file to your project if you haven't already.  
Make sure to remove the check for **Copy items if needed** 

4. You can now simply use the `plist` file however you like or use the `Acknowledgement` model for convenience:

```swift
import AckGen
// ...
let acknowledgements: [Acknowledgement] = Acknowledgement.all()
acknowledgements.forEach { print($0.title, $0.license) }
```

## UI

Optionally, there's a basic SwiftUI `AcknowledgementsList` component (see gif above) included in the `AckGenUI` module that you can use to quickly create a generic list of acknowledgements to embed into a `NavigationView`.

```swift
import AckGenUI
import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            AcknowledgementsList()
        }
    }
}
```

## Beta

Until 1.0 is reached, minor versions will be breaking.

## Troubleshooting

### "AckGen not found" Error

If you see the warning `AckGen not found. Please install the package via SPM`, try the following:

1. **Run the diagnostic script**: 
   - Swift version: `swift diagnose_path.swift` (set `PROJECT_TEMP_DIR` environment variable first)
   - Shell version: `./diagnose_path.sh` (set `PROJECT_TEMP_DIR` environment variable first)
2. **Verify SPM installation**: Make sure AckGen is added as a Swift Package dependency in your Xcode project
3. **Build your project**: SPM dependencies are only downloaded after you build your project at least once
4. **Check your path**: The script in the README dynamically calculates the package path. If your project uses a non-standard structure, you may need to adjust the path calculation

#### Understanding Path Detection

Xcode places SPM packages in different locations depending on your project setup. The recommended script uses:

```sh
BASE_DIR="${PROJECT_TEMP_DIR%/Build/*}"
DIR="$BASE_DIR/SourcePackages/checkouts/AckGen"
```

This uses bash parameter expansion to remove everything from `/Build/` onwards (including `/Build/` itself) and appends the standard SPM checkout path. This approach:
- Works across different Xcode versions
- Handles Debug/Release configurations  
- Supports iOS/macOS/watchOS/tvOS targets
- Works with Simulator/Device builds
- Handles edge cases like usernames or project names containing "Build"

The calculation finds the **last** occurrence of `/Build/` in the path, ensuring correct behavior even when "Build" appears elsewhere in the path (e.g., `/Users/Build/Projects/MyApp/Build/Intermediates`).

If you need a different path for your setup (e.g., local package development), you can modify the `DIR` variable accordingly. See `Example/ackgen.sh` for an example of using a local package.

## Contribution

This is my first stab at building a Swift package and was mainly intended to be an exercise.  
I hope, however, that it can be useful to someone other than me. 

If you encounter any problems or have suggestions, additions or possible improvements to share, you are more than welcome to open a PR or issue and I'll get back to you as soon as my time allows it.

### Setup Example App

```sh
make bootstrap
make open
```

## TODO

- [ ] Add non-SPM licenses separately
- [x] Add UI components (SwiftUI List with NavigationLink to license info?)
- [ ] Allow Run Script Output Files as alternative to command line argument
- [ ] Allow to specify excluded packages
- [ ] Add tests
- [ ] Add other platforms
