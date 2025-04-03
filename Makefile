.PHONY: setup bootstrap
setup bootstrap:
	mint bootstrap
	touch Example/PackageLicenses.plist
	rm -rf Example/*.xcodeproj
	mint run xcodegen generate --spec Example/project.yml

.PHONY: open
open:
	xed Example
