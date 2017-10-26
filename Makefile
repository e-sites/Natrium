all: help

build:
	swiftlint; swift build -Xswiftc -static-stdlib -c release
	cp .build/release/natrium bin/
	chmod +x bin/natrium
	cp bin/natrium Example/Pods/Natrium/bin/

help:
	@echo "Available make commands:"
	@echo "   $$ make help - display this message"
	@echo "   $$ make build - creates a new build"
