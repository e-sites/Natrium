all: help

build:
	cd lib; swift build -Xswiftc -static-stdlib -c release
	cp lib/.build/release/natrium bin/
	cp lib/.build/release/natrium Example/Pods/Natrium/bin/

help:
	@echo "Available make commands:"
	@echo "   $$ make help - display this message"
	@echo "   $$ make build - creates a new build"
