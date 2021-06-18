all: help

build:
	make xcodeproj
	swiftlint
	xcodebuild -project Natrium.xcodeproj -scheme Natrium -configuration Release -arch x86_64 -arch arm64 ONLY_ACTIVE_ARCH=NO BUILD_DIR="./Natrium/"
	mv ./Natrium/Release/Natrium ./Natrium/natrium
	rm -rf ./Natrium/Release
	chmod +x Natrium/natrium
	mkdir -p Example/Cocoapods/Pods/Natrium/Natrium/Sources
	chmod -R 7777 Example/CocoaPods/Pods/Natrium/
	cp Natrium/Sources/*.* Example/CocoaPods/Pods/Natrium/Natrium/Sources/
	cp Natrium/natrium Example/CocoaPods/Pods/Natrium/Natrium/
	rm -rf Example/CocoaPods/Pods/Natrium/Natrium.lock
	cp Natrium/natrium Example/Manual/
	rm -rf Example/Manual/Natrium.lock
	rm -rf Res/Natrium.framewok/run
	cp Natrium/natrium Res/Natrium.framework/run
	rm -rf Res/Natrium.framewok.zip
	zip -r -X "Res/Natrium.framework.zip" Res/Natrium.framework/*
	sh Res/update_version_json.sh

xcodeproj:
	mv ./Package.swift ./Package.swift_; mv ./Package.local.swift ./Package.swift
	swift package generate-xcodeproj
	mv ./Package.swift ./Package.local.swift; mv ./Package.swift_ ./Package.swift

help:
	@echo "Available make commands:"
	@echo "   $$ make help - display this message"
	@echo "   $$ make build - creates a new build"
	@echo "   $$ make xcodeproj - creates a xcodeproj"
