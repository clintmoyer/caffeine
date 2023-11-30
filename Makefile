# Makefile

all: xcode download

# Setup xcode directory
xcode:
	mkdir -p caffeine.xcodeproj
	cp project.pbxproj caffeine.xcodeproj/project.pbxproj

# Target for downloading the files
download:
	wget -O active.png https://i.imgur.com/GD9rxDR.png
	wget -O inactive.png https://i.imgur.com/nKvKun2.png

# Phony targets
.PHONY: all xcode download

