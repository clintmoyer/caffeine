![mug](https://github.com/user-attachments/assets/6002a312-fa46-4edf-a909-44639d7b1557)

# Caffeine

Caffeine is a lightweight macOS menu bar application that prevents your Mac from going to sleep, dimming the screen, or activating the screen saver. It’s designed to be simple and easy to use, offering quick toggling of sleep prevention directly from the menu bar.

## Features

- Toggle sleep prevention with a single click from the menu bar.
- Visual indicators for active (Caffeine enabled) and inactive states.
- Minimal system resource usage while running.
- Easily quit the application from the menu bar.

## Requirements

- macOS 10.14 or higher.
- Swift 5.0 or higher.
- rsvg-convert (for converting SVG icons to PNG).

## Installation

This will compile the program, package the app, and create the DMG.

```bash
git clone https://github.com/clintmoyer/caffeine.git
cd caffeine
make
```

## How It Works

Caffeine uses the macOS IOKit power management system to create an assertion that prevents the display from sleeping. When Caffeine is active, it creates a `kIOPMAssertionTypeNoDisplaySleep` assertion, which keeps the display on indefinitely. When deactivated, the assertion is released, allowing the system to manage power as usual.

## Usage

- **Left-click** the Caffeine icon in the menu bar to toggle the sleep prevention on and off.
- **Right-click** to access the menu, which includes a "Quit" option to terminate the app.

## Running Tests

To run the unit tests for Caffeine, use the `test` target in the Makefile:

```bash
make test
```

This will compile and run the tests defined in `tests.swift` and ensure that the core functionality (activating, deactivating, and toggling Caffeine) works as expected.
