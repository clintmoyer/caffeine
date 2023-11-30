# Makefile to download and overwrite files

all: download

# Target for downloading the files
download:
	wget -O active.png https://i.imgur.com/GD9rxDR.png
	wget -O inactive.png https://i.imgur.com/nKvKun2.png

# Phony targets
.PHONY: all download

