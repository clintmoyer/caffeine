// Copyright 2023 Clint Moyer
//
// This file is part of Caffeine.
//
// Caffeine is free software: you can redistribute it and/or modify it under the
// terms of the GNU General Public License as published by the Free Software
// Foundation, either version 3 of the License, or (at your option) any later
// version.
//
// Caffeine is distributed in the hope that it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
// PARTICULAR PURPOSE.  See the GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License along with
// Caffeine.  If not, see <https://www.gnu.org/licenses/>.

import XCTest
@testable import Caffeine

final class CaffeineTests: XCTestCase {
	var menuBarManager: MenuBarManager!

	override func setUpWithError() throws {
		super.setUp()
		// Initialize the MenuBarManager or other components you want to test
		menuBarManager = MenuBarManager()
	}

	override func tearDownWithError() throws {
		// Clean up
		menuBarManager = nil
		super.tearDown()
	}

	func testMenuBarManagerInitialization() throws {
		// Test the initial state of the MenuBarManager
		XCTAssertNotNil(menuBarManager, "MenuBarManager should be initialized")
		// Add other assertions relevant to its initial state
	}

	func testToggleCaffeinateFunctionality() throws {
		// Ensure the caffeinate process is nil initially
		XCTAssertNil(menuBarManager.caffeinateProcess, "Caffeinate process should be nil initially")

		// Simulate starting the caffeinate process
		menuBarManager.startCaffeinate()
		XCTAssertNotNil(menuBarManager.caffeinateProcess, "Caffeinate process should not be nil after starting")

		// Simulate stopping the caffeinate process
		menuBarManager.stopCaffeinate()
		XCTAssertNil(menuBarManager.caffeinateProcess, "Caffeinate process should be nil after stopping")
	}


	func testMenuBarIconUpdate() throws {
		// Initially, the icon should be the inactive one
		XCTAssertEqual(menuBarManager.statusBarItem.button?.image, NSImage(named: "InactiveMenuBarIcon"), "Initial icon should be inactive")

		// Simulate activating the caffeinate process
		menuBarManager.startCaffeinate()
		menuBarManager.updateMenuBarIcon()
		XCTAssertEqual(menuBarManager.statusBarItem.button?.image, NSImage(named: "ActiveMenuBarIcon"), "Icon should be active after starting caffeinate")

		// Simulate deactivating the caffeinate process
		menuBarManager.stopCaffeinate()
		menuBarManager.updateMenuBarIcon()
		XCTAssertEqual(menuBarManager.statusBarItem.button?.image, NSImage(named: "InactiveMenuBarIcon"), "Icon should be inactive after stopping caffeinate")
	}

}
