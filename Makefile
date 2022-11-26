.PHONY: setup
setup:
	touch Example/PackageLicenses.plist
	rm -rf Example/*.xcodeproj
	mint run xcodegen generate --spec Example/project.yml
