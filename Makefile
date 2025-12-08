INSTALL_DIR ?= ~/Applications

SWIFT_FLAGS = -O

APP_NAME = Caffeine
BUNDLE_ID = com.clintmoyer.caffeine
MIN_MACOS_VERSION = 11.0

BUILD_DIR = .build

.PHONY: all build install uninstall clean test

all: build

build:
	swift build -c release --arch x86_64
	swift build -c release --arch arm64
	mkdir -p $(APP_NAME).app/Contents/MacOS
	lipo -create -output $(APP_NAME).app/Contents/MacOS/$(APP_NAME) $(BUILD_DIR)/x86_64-apple-macosx/release/$(APP_NAME) $(BUILD_DIR)/arm64-apple-macosx/release/$(APP_NAME)
	cp Info.plist $(APP_NAME).app/Contents/Info.plist

test:
	swift test

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
	rm -rf $(APP_NAME).app $(BUILD_DIR) *.dSYM

.DEFAULT_GOAL := build
