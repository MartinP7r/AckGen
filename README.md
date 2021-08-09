# AckGen

Simple **Ack**nowledgements **Gen**erator for SPM package license information.

## Overview

It automatically generates a `plist` file containing the title and license information for all Swift packages used in your project.  
This can be used to feed a SwiftUI List or UITableView dataSource in your app.

|||
|---|---|
| ![](docs/demo.gif) | ![](docs/sample_plist.png) |

## Installation

1. Add AckGen as a dependency for your project in Xcode.  

2. Add the following as a Run Script for your target in Xcode

```sh
DIR=$PROJECT_TEMP_DIR/../../../SourcePackages/checkouts/AckGen
if [ -d "$DIR" ]; then
  cd $DIR
  SDKROOT=macosx
  swift run ackgen
else
  echo "warning: AckGen not found. Please install the package via SPM (https://github.com/MartinP7r/AckGen#installation)"
fi
```

If you want the plist file to be saved somewhere other than `Acknowledgements.plist` at the root of your project (`$SRCROOT/Acknowledgements.plist`), you can provide a custom path as the first command line argument to `ackgen` above. 

```sh
  swift run ackgen $SRCROOT/PackageLicenses.plist
```

3. Add the generated `plist` file to your project if you haven't already.  
Make sure to remove the check for **Copy items if needed** 

## Beta

Until 1.0 is reached, minor versions will be breaking.

## TODO

- [ ] Add non-SPM licenses separately
- [ ] Add UI components (SwiftUI List with NavigationLink to license info?)
- [ ] Allow Run Script Output Files as alternative to command line argument
- [ ] Allow to specify excluded packages
