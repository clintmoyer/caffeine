// Copyright 2023 Clint Moyer
//
// This program is free software: you can redistribute it and/or modify it under
// the terms of the GNU General Public License as published by the Free Software
// Foundation, either version 3 of the License, or (at your option) any later
// version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
// PARTICULAR PURPOSE. See the GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License along with
// this program. If not, see <https://www.gnu.org/licenses/>.

import AppKit
import SwiftUI

@main
struct CaffeineApp: App {
	@NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

	var body: some Scene {
		Settings {
			EmptyView()
		}
	}
}

class AppDelegate: NSObject, NSApplicationDelegate {
	var menuBarManager: MenuBarManager?

	func applicationDidFinishLaunching(_ notification: Notification) {
		menuBarManager = MenuBarManager()
	}
}

class MenuBarManager: NSObject {
	var statusBarItem: NSStatusItem!
	var caffeinateProcess: Process?
	var menu: NSMenu?

	// Lazy-loaded images
	lazy var activeImage = NSImage(named: "active")
	lazy var inactiveImage = NSImage(named: "inactive")

	override init() {
		super.init()
		setUpStatusBar()
		setUpMenu()
	}

	func setUpStatusBar() {
		statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

		if let button = statusBarItem.button {
			button.image = inactiveImage // Use the lazy-loaded image
			button.action = #selector(toggleCaffeinate(_:))
			button.target = self
			button.sendAction(on: [.leftMouseUp, .rightMouseUp])
		}
	}

	func setUpMenu() {
		menu = NSMenu()
		let quitMenuItem = NSMenuItem(title: "Quit", action: #selector(quitApp), keyEquivalent: "q")
		quitMenuItem.target = self
		menu?.addItem(quitMenuItem)
	}

	@objc func toggleCaffeinate(_ sender: Any?) {
		guard let event = NSApp.currentEvent else { return }

		if event.type == .rightMouseUp {
			statusBarItem.menu = menu
			statusBarItem.button?.performClick(nil)
			statusBarItem.menu = nil
		} else {
			if caffeinateProcess == nil {
				startCaffeinate()
			} else {
				stopCaffeinate()
			}
			updateMenuBarIcon()
		}
	}

	func startCaffeinate() {
		let process = Process()
		process.launchPath = "/usr/bin/caffeinate"
		process.arguments = ["-di"]
		process.launch()
		caffeinateProcess = process
	}

	func stopCaffeinate() {
		caffeinateProcess?.terminate()
		caffeinateProcess = nil
	}

	func updateMenuBarIcon() {
		if let button = statusBarItem.button {
			button.image = caffeinateProcess != nil ? activeImage : inactiveImage
		}
	}

	@objc private func quitApp() {
		stopCaffeinate()
		NSApp.terminate(nil)
	}
}

