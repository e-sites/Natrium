all: help

build:
	swiftlint; swift build -Xswiftc -static-stdlib -c release
	cp .build/release/natrium bin/
	chmod +x bin/natrium
	chmod -R 7777 Example/Pods/Natrium/bin/
	cp bin/* Example/Pods/Natrium/bin/
	rm -rf Example/Pods/Natrium/bin/Natrium.lock

help:
	@echo "Available make commands:"
	@echo "   $$ make help - display this message"
	@echo "   $$ make build - creates a new build"
