all: help

build:
	cd lib; swift build -Xswiftc -static-stdlib
	cp lib/.build/debug/natrium bin/

help:
	@echo "Available make commands:"
	@echo "   $$ make help - display this message"
	@echo "   $$ make build - creates a new build"
