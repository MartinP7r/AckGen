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
DIR=$PROJECT_TEMP_DIR/../../../SourcePackages/checkouts/AckGen
if [ -d "$DIR" ]; then
  cd $DIR
  SDKROOT=(xcrun --sdk macosx --show-sdk-path)
  swift run ackgen
else
  echo "warning: AckGen not found. Please install the package via SPM (https://github.com/MartinP7r/AckGen#installation)"
fi
```

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

## Settings.bundle Integration

AckGen can generate acknowledgements in a format compatible with iOS Settings.bundle, allowing users to view package licenses directly in the iOS Settings app.

### Setup

1. Create a `Settings.bundle` in your Xcode project if you don't have one already (File → New → File → Settings Bundle).

2. In your Settings.bundle's `Root.plist`, add a child pane specifier that points to the acknowledgements:

```xml
<dict>
    <key>Type</key>
    <string>PSChildPaneSpecifier</string>
    <key>File</key>
    <string>Acknowledgements</string>
    <key>Title</key>
    <string>Acknowledgements</string>
</dict>
```

3. Add a Run Script build phase that generates the acknowledgements file in Settings.bundle format:

```sh
DIR=$PROJECT_TEMP_DIR/../../../SourcePackages/checkouts/AckGen
if [ -d "$DIR" ]; then
    cd $DIR
    SDKROOT=$(xcrun --sdk macosx --show-sdk-path)
    SETTINGS_BUNDLE=$(find "$SRCROOT" -type d -name "Settings.bundle" -print -quit)
    
    if [ -d "$SETTINGS_BUNDLE" ]; then
        PLIST_PATH="$SETTINGS_BUNDLE/Acknowledgements.plist"
        PROJECT_NAME=$(basename "$SRCROOT")
        swift run ackgen "$PLIST_PATH" 1 "$PROJECT_NAME"
    else
        echo "warning: Settings.bundle not found in the project."
    fi
else
    echo "warning: AckGen not found. Please install the package via SPM (https://github.com/MartinP7r/AckGen#installation)"
fi
```

The command takes three arguments:
- **Path**: Where to save the plist file (e.g., `$SETTINGS_BUNDLE/Acknowledgements.plist`)
- **Settings mode flag**: Pass `1` to generate Settings.bundle compatible format
- **Title** (optional): The title for the acknowledgements section (defaults to "Acknowledgements")

4. Make sure the generated `Acknowledgements.plist` is ignored in your `.gitignore` (e.g., `Settings.bundle/Acknowledgements.plist`) as it will be regenerated on each build.

The acknowledgements will now appear in your app's Settings screen.

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
