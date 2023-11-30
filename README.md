![coffeemug](https://i.imgur.com/mfVLgnA.png)

# Caffeine

Caffeine is a lightweight, simple tool for macOS. Its purpose is to prevent
your Mac from automatically going to sleep, dimming the screen, or starting
screen savers. It's easy to use, lives in your menu bar, and it's a perfect
tool for uninterrupted work sessions.

## Features

- Easy click activation and deactivation
- Uses less than 15MB of memory

## Install

Download and install in just seconds:

https://github.com/clintmoyer/caffeine/releases/latest

## How it works

Uses the builtin `caffeinate` tool with MacOS.

https://opensource.apple.com/source/PowerManagement/PowerManagement-1132.141.1/caffeinate/caffeinate.c.auto.html

More specifically:

* IOPM library assertions (Input/Output Power Management)
* kDisplayAssertionFlag / kIdleAssertionFlag
* Grand Central Dispatch for timeouts

