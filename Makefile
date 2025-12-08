INSTALL_DIR ?= ~/Applications

SWIFT_FLAGS = -O

APP_NAME = Caffeine
BUNDLE_ID = com.clintmoyer.caffeine
MIN_MACOS_VERSION = 11.0

.PHONY: all build install uninstall clean
all: build
build:
	mkdir -p $(APP_NAME).app/Contents/MacOS
	swiftc $(SWIFT_FLAGS) -target x86_64-apple-macos$(MIN_MACOS_VERSION) Caffeine.swift -o Caffeine_x86_64
	swiftc $(SWIFT_FLAGS) -target arm64-apple-macos$(MIN_MACOS_VERSION) Caffeine.swift -o Caffeine_arm64
	lipo -create -output $(APP_NAME).app/Contents/MacOS/$(APP_NAME) Caffeine_x86_64 Caffeine_arm64
	rm -f Caffeine_x86_64 Caffeine_arm64
	cp Info.plist $(APP_NAME).app/Contents/Info.plist

install: build
	mkdir -p $(INSTALL_DIR)
	cp -R $(APP_NAME).app $(INSTALL_DIR)/
	@echo "Caffeine installed to $(INSTALL_DIR)/$(APP_NAME).app"
	@echo ""
	@echo "To start Caffeine, run: open $(INSTALL_DIR)/$(APP_NAME).app"
	@echo "To run at login, add to Login Items in System Settings"

uninstall:
	rm -rf $(INSTALL_DIR)/$(APP_NAME).app
	@echo "Caffeine uninstalled"

clean:
	rm -rf $(APP_NAME).app Caffeine_* *.dSYM

.DEFAULT_GOAL := build
