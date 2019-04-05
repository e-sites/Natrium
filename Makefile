all: help

build:
	swiftlint; swift build --configuration release
	cp .build/release/natrium bin/
	chmod +x bin/natrium
	mkdir -p Example/Cocoapods/Pods/Natrium/bin
	chmod -R 7777 Example/CocoaPods/Pods/Natrium/bin/
	cp bin/*.swift Example/CocoaPods/Pods/Natrium/bin/
	cp bin/natrium Example/CocoaPods/Pods/Natrium/bin/
	cp bin/Natrium.h Example/CocoaPods/Pods/Natrium/bin/
	rm -rf Example/CocoaPods/Pods/Natrium/bin/Natrium.lock
	cp bin/natrium Example/Manual/
	rm -rf Example/Manual/Natrium.lock
	rm -rf Res/Natrium.framewok/run
	cp bin/natrium Res/Natrium.framework/run
	rm -rf Res/Natrium.framewok.zip
	zip -r -X "Res/Natrium.framework.zip" Res/Natrium.framework/*
	sh Res/update_version_json.sh

help:
	@echo "Available make commands:"
	@echo "   $$ make help - display this message"
	@echo "   $$ make build - creates a new build"
