/*
Copyright 2025 Clint Moyer (contact@clintmoyer.com)

This file is part of Caffeine.

Caffeine is free software: you can redistribute it and/or modify it under the
terms of the GNU General Public License as published by the Free Software
Foundation, either version 3 of the License, or (at your option) any later version.

Caffeine is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with Caffeine.
If not, see <https://www.gnu.org/licenses/>.
*/
import Cocoa

// Controls the menu bar status item and its interactions
public final class StatusBarController {

	// The status item displayed in the menu bar
	private var statusItem: NSStatusItem?

	// The power manager instance
	private let powerManager: PowerManager

	// The menu shown on right-click
	private lazy var contextMenu: NSMenu = {
		let menu = NSMenu()
		let quitItem = NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q")
		quitItem.target = self
		menu.addItem(quitItem)
		return menu
	}()

	// SF Symbol name for inactive state
	private let inactiveIcon = "cup.and.heat.waves"

	// SF Symbol name for active state
	private let activeIcon = "cup.and.heat.waves.fill"

	public init(powerManager: PowerManager) {
		self.powerManager = powerManager
	}

	// Sets up the status bar item
	public func setup() {
		statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

		guard let button = statusItem?.button else { return }

		updateIcon()

		button.target = self
		button.action = #selector(handleClick)
		button.sendAction(on: [.leftMouseUp, .rightMouseUp])
	}

	// Handles clicks on the status bar item
	@objc private func handleClick(_ sender: NSStatusBarButton) {
		guard let event = NSApp.currentEvent else { return }

		if event.type == .rightMouseUp {
			showContextMenu()
		} else {
			toggleState()
		}
	}

	// Shows the context menu on right-click
	private func showContextMenu() {
		guard let button = statusItem?.button else { return }
		statusItem?.menu = contextMenu
		button.performClick(nil)
		statusItem?.menu = nil
	}

	// Toggles the caffeine state
	private func toggleState() {
		powerManager.toggle()
		updateIcon()
	}

	// Updates the icon based on the current state
	private func updateIcon() {
		guard let button = statusItem?.button else { return }

		let iconName = powerManager.isActive ? activeIcon : inactiveIcon
		let config = NSImage.SymbolConfiguration(pointSize: 16, weight: .regular)

		if let image = NSImage(systemSymbolName: iconName, accessibilityDescription: "Caffeine") {
			let configuredImage = image.withSymbolConfiguration(config)
			button.image = configuredImage
		}
	}

	// Quits the application
	@objc private func quit() {
		powerManager.deactivate()
		NSApplication.shared.terminate(nil)
	}

	// Returns the current active state (for testing)
	public var isActive: Bool {
		powerManager.isActive
	}
}
