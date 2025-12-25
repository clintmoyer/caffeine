# Makefile for Caffeine - macOS menu bar app to prevent system sleep
# Following GNU Coding Standards

# Package information
PACKAGE = Caffeine
VERSION = 1.0.0
BUNDLE_ID = com.clintmoyer.caffeine

# Build configuration
SWIFT = swift
SWIFT_BUILD_FLAGS = -c release
SWIFT_TEST_FLAGS =
ICONUTIL = iconutil

# Installation directories
prefix = /usr/local
exec_prefix = $(prefix)
bindir = $(exec_prefix)/bin
datarootdir = $(prefix)/share
datadir = $(datarootdir)

# macOS specific installation
APPLICATIONS_DIR = /Applications
APP_NAME = $(PACKAGE).app
APP_BUNDLE = $(APP_NAME)

# Build directories
BUILD_DIR = .build
RELEASE_DIR = $(BUILD_DIR)/release
DEBUG_DIR = $(BUILD_DIR)/debug

# Executables and resources
EXECUTABLE = $(PACKAGE)
ICON_SET = $(PACKAGE).iconset
ICON_FILE = $(PACKAGE).icns
# Icon URL - Update this to a direct image URL or place icon-source.png manually
ICON_URL = https://i.imgur.com/zbUTJ7e.png
ICON_SOURCE = icon-source.png
INFO_PLIST = Info.plist

# Installation commands
INSTALL = install
INSTALL_PROGRAM = $(INSTALL)
INSTALL_DATA = $(INSTALL) -m 644
MKDIR_P = mkdir -p
RM = rm -f
RM_R = rm -rf

# DESTDIR support for staged installs
DESTDIR =

.PHONY: all build icon app clean distclean mostlyclean maintainer-clean \
        install install-strip uninstall installdirs check dist \
        generate-info-plist download-icon generate-iconset

# Default target - compile the entire program
all: build icon app

# Generate Info.plist
generate-info-plist: $(INFO_PLIST)

$(INFO_PLIST):
	@echo "Generating Info.plist..."
	@echo '<?xml version="1.0" encoding="UTF-8"?>' > $(INFO_PLIST)
	@echo '<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">' >> $(INFO_PLIST)
	@echo '<plist version="1.0">' >> $(INFO_PLIST)
	@echo '<dict>' >> $(INFO_PLIST)
	@echo '	<key>CFBundleDevelopmentRegion</key>' >> $(INFO_PLIST)
	@echo '	<string>en</string>' >> $(INFO_PLIST)
	@echo '	<key>CFBundleExecutable</key>' >> $(INFO_PLIST)
	@echo '	<string>$(EXECUTABLE)</string>' >> $(INFO_PLIST)
	@echo '	<key>CFBundleIconFile</key>' >> $(INFO_PLIST)
	@echo '	<string>$(ICON_FILE)</string>' >> $(INFO_PLIST)
	@echo '	<key>CFBundleIdentifier</key>' >> $(INFO_PLIST)
	@echo '	<string>$(BUNDLE_ID)</string>' >> $(INFO_PLIST)
	@echo '	<key>CFBundleInfoDictionaryVersion</key>' >> $(INFO_PLIST)
	@echo '	<string>6.0</string>' >> $(INFO_PLIST)
	@echo '	<key>CFBundleName</key>' >> $(INFO_PLIST)
	@echo '	<string>$(PACKAGE)</string>' >> $(INFO_PLIST)
	@echo '	<key>CFBundlePackageType</key>' >> $(INFO_PLIST)
	@echo '	<string>APPL</string>' >> $(INFO_PLIST)
	@echo '	<key>CFBundleShortVersionString</key>' >> $(INFO_PLIST)
	@echo '	<string>$(VERSION)</string>' >> $(INFO_PLIST)
	@echo '	<key>CFBundleVersion</key>' >> $(INFO_PLIST)
	@echo '	<string>$(VERSION)</string>' >> $(INFO_PLIST)
	@echo '	<key>LSMinimumSystemVersion</key>' >> $(INFO_PLIST)
	@echo '	<string>13.0</string>' >> $(INFO_PLIST)
	@echo '	<key>LSUIElement</key>' >> $(INFO_PLIST)
	@echo '	<true/>' >> $(INFO_PLIST)
	@echo '	<key>NSHighResolutionCapable</key>' >> $(INFO_PLIST)
	@echo '	<true/>' >> $(INFO_PLIST)
	@echo '</dict>' >> $(INFO_PLIST)
	@echo '</plist>' >> $(INFO_PLIST)
	@echo "Info.plist generated successfully"

# Build the Swift executable
build:
	$(SWIFT) build $(SWIFT_BUILD_FLAGS)

# Download icon from URL
download-icon: $(ICON_SOURCE)

$(ICON_SOURCE):
	@echo "Downloading icon from $(ICON_URL)..."
	@curl -L -o $(ICON_SOURCE) "$(ICON_URL)"
	@echo "Icon downloaded successfully"

# Generate iconset from downloaded icon
generate-iconset: $(ICON_SET)

$(ICON_SET): $(ICON_SOURCE)
	@echo "Generating iconset..."
	@$(MKDIR_P) $(ICON_SET)
	@sips -z 16 16     $(ICON_SOURCE) --out $(ICON_SET)/icon_16x16.png > /dev/null
	@sips -z 32 32     $(ICON_SOURCE) --out $(ICON_SET)/icon_16x16@2x.png > /dev/null
	@sips -z 32 32     $(ICON_SOURCE) --out $(ICON_SET)/icon_32x32.png > /dev/null
	@sips -z 64 64     $(ICON_SOURCE) --out $(ICON_SET)/icon_32x32@2x.png > /dev/null
	@sips -z 128 128   $(ICON_SOURCE) --out $(ICON_SET)/icon_128x128.png > /dev/null
	@sips -z 256 256   $(ICON_SOURCE) --out $(ICON_SET)/icon_128x128@2x.png > /dev/null
	@sips -z 256 256   $(ICON_SOURCE) --out $(ICON_SET)/icon_256x256.png > /dev/null
	@sips -z 512 512   $(ICON_SOURCE) --out $(ICON_SET)/icon_256x256@2x.png > /dev/null
	@sips -z 512 512   $(ICON_SOURCE) --out $(ICON_SET)/icon_512x512.png > /dev/null
	@sips -z 1024 1024 $(ICON_SOURCE) --out $(ICON_SET)/icon_512x512@2x.png > /dev/null
	@echo "Iconset generated successfully"

# Generate the icon file from iconset
icon: $(ICON_FILE)

$(ICON_FILE): $(ICON_SET)
	@if [ -d "$(ICON_SET)" ]; then \
		$(ICONUTIL) -c icns -o $(ICON_FILE) $(ICON_SET); \
	else \
		echo "Warning: $(ICON_SET) not found, skipping icon generation"; \
	fi

# Create the application bundle
app: build icon $(INFO_PLIST)
	@echo "Creating application bundle..."
	@$(MKDIR_P) $(APP_BUNDLE)/Contents/MacOS
	@$(MKDIR_P) $(APP_BUNDLE)/Contents/Resources
	@cp $(RELEASE_DIR)/$(EXECUTABLE) $(APP_BUNDLE)/Contents/MacOS/
	@cp $(INFO_PLIST) $(APP_BUNDLE)/Contents/
	@if [ -f "$(ICON_FILE)" ]; then \
		cp $(ICON_FILE) $(APP_BUNDLE)/Contents/Resources/; \
	fi
	@echo "Application bundle created: $(APP_BUNDLE)"

# Compile the program and install it
install: all installdirs
	@echo "Installing $(APP_NAME)..."
	@if [ -d "$(DESTDIR)$(APPLICATIONS_DIR)/$(APP_NAME)" ]; then \
		$(RM_R) "$(DESTDIR)$(APPLICATIONS_DIR)/$(APP_NAME)"; \
	fi
	@cp -R $(APP_BUNDLE) "$(DESTDIR)$(APPLICATIONS_DIR)/"
	@echo "$(APP_NAME) installed to $(DESTDIR)$(APPLICATIONS_DIR)"
	@echo "Installation complete."

# Install with stripped executables
install-strip:
	$(MAKE) INSTALL_PROGRAM='$(INSTALL_PROGRAM) -s' install

# Remove installed files
uninstall:
	@echo "Uninstalling $(APP_NAME)..."
	@if [ -d "$(DESTDIR)$(APPLICATIONS_DIR)/$(APP_NAME)" ]; then \
		$(RM_R) "$(DESTDIR)$(APPLICATIONS_DIR)/$(APP_NAME)"; \
		echo "$(APP_NAME) removed from $(DESTDIR)$(APPLICATIONS_DIR)"; \
	else \
		echo "$(APP_NAME) not found in $(DESTDIR)$(APPLICATIONS_DIR)"; \
	fi

# Create installation directories
installdirs:
	@$(MKDIR_P) "$(DESTDIR)$(APPLICATIONS_DIR)"

# Run tests
check:
	$(SWIFT) test $(SWIFT_TEST_FLAGS)

# Clean build artifacts
clean:
	@echo "Cleaning build artifacts..."
	@$(RM_R) $(BUILD_DIR)
	@$(RM_R) $(APP_BUNDLE)
	@$(RM) $(ICON_FILE)
	@$(RM) $(INFO_PLIST)
	@echo "Clean complete."

# Clean everything except distribution files
distclean: clean
	@echo "Performing distclean..."
	@$(RM_R) .swiftpm
	@echo "Distclean complete."

# Clean most things (like clean but preserve some artifacts)
mostlyclean: clean

# Clean everything that can be rebuilt
maintainer-clean: distclean
	@echo 'This command is intended for maintainers to use; it'
	@echo 'deletes files that may need special tools to rebuild.'
	@$(RM_R) $(ICON_SET)
	@$(RM) $(ICON_SOURCE)
	@echo "Maintainer clean complete."

# Create a distribution tarball
dist: distclean
	@echo "Creating distribution tarball..."
	@$(MKDIR_P) $(PACKAGE)-$(VERSION)
	@cp -R Sources Tests Package.swift Info.plist $(ICON_SET) $(PACKAGE)-$(VERSION)/ 2>/dev/null || true
	@if [ -f "README.md" ]; then cp README.md $(PACKAGE)-$(VERSION)/; fi
	@if [ -f "LICENSE" ]; then cp LICENSE $(PACKAGE)-$(VERSION)/; fi
	@cp Makefile $(PACKAGE)-$(VERSION)/
	@tar czf $(PACKAGE)-$(VERSION).tar.gz $(PACKAGE)-$(VERSION)
	@$(RM_R) $(PACKAGE)-$(VERSION)
	@echo "Distribution created: $(PACKAGE)-$(VERSION).tar.gz"

# Help target
help:
	@echo "Available targets:"
	@echo "  all                  - Build the application (default)"
	@echo "  build                - Compile the Swift executable"
	@echo "  generate-info-plist  - Generate Info.plist from variables"
	@echo "  download-icon        - Download icon from URL"
	@echo "  generate-iconset     - Generate iconset from downloaded icon"
	@echo "  icon                 - Generate the application icon (.icns)"
	@echo "  app                  - Create the application bundle"
	@echo "  install              - Install the application to $(APPLICATIONS_DIR)"
	@echo "  install-strip        - Install with stripped executables"
	@echo "  uninstall            - Remove the installed application"
	@echo "  check                - Run tests"
	@echo "  clean                - Remove build artifacts"
	@echo "  distclean            - Remove all generated files"
	@echo "  mostlyclean          - Like clean"
	@echo "  maintainer-clean     - Remove everything that can be rebuilt"
	@echo "  dist                 - Create distribution tarball"
	@echo "  installdirs          - Create installation directories"
	@echo "  help                 - Show this help message"
