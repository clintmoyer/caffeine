APP_NAME = Caffeine
SRC_FILE = caffeine.swift
PLIST_FILE = info.plist
BUNDLE_NAME = $(APP_NAME).app
RESOURCES_DIR = $(BUNDLE_NAME)/Contents/Resources
EXECUTABLE_DIR = $(BUNDLE_NAME)/Contents/MacOS
TEST_FILE = tests.swift

all: $(BUNDLE_NAME)

active.png: active.svg
	rsvg-convert -o active.png active.svg

inactive.png: inactive.svg
	rsvg-convert -o inactive.png inactive.svg

$(APP_NAME): $(SRC_FILE)
	swiftc -o $(APP_NAME) $(SRC_FILE)

$(BUNDLE_NAME): $(APP_NAME) active.png inactive.png $(PLIST_FILE)
	# Create necessary directories
	mkdir -p $(EXECUTABLE_DIR)
	mkdir -p $(RESOURCES_DIR)
	# Copy the executable and plist file
	cp $(APP_NAME) $(EXECUTABLE_DIR)/
	cp $(PLIST_FILE) $(BUNDLE_NAME)/Contents/Info.plist
	# Copy the PNG images to the Resources folder
	cp active.png inactive.png $(RESOURCES_DIR)/

test:
	swiftc -o test_runner $(SRC_FILE) $(TEST_FILE) -Xlinker -bundle -framework XCTest
	./test_runner

clean:
	rm -rf $(APP_NAME) $(BUNDLE_NAME) active.png inactive.png test_runner

