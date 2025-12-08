PREFIX ?= /usr/local
BINDIR = $(PREFIX)/bin

ARCH := $(shell uname -m)
ifeq ($(ARCH),x86_64)
SWIFT_FLAGS = -O -target x86_64-apple-macosx11.0
else ifeq ($(ARCH),arm64)
SWIFT_FLAGS = -O -target arm64-apple-macosx11.0
else
$(error Unsupported architecture: $(ARCH))
endif

.PHONY: all build install uninstall clean
all: build
build:
	swiftc $(SWIFT_FLAGS) caffeine.swift -o caffeine
install: build
	mkdir -p $(BINDIR)
	install -m 755 caffeine $(BINDIR)/caffeine
	@echo "Caffeine installed to $(BINDIR)/caffeine"
	@echo ""
	@echo "To start Caffeine, run: caffeine"
	@echo "To run at login, add to Login Items in System Preferences"
uninstall:
	rm -f $(BINDIR)/caffeine
	@echo "Caffeine uninstalled"
clean:
	rm -f caffeine
	rm -rf *.dSYM
.DEFAULT_GOAL := build
