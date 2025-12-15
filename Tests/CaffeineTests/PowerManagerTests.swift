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
import XCTest
@testable import Caffeine

final class PowerManagerTests: XCTestCase {

	var powerManager: PowerManager!

	override func setUp() {
		super.setUp()
		powerManager = PowerManager(name: "CaffeineTest", reason: "Unit testing")
	}

	override func tearDown() {
		powerManager.deactivate()
		powerManager = nil
		super.tearDown()
	}

	func testInitialState() {
		XCTAssertFalse(powerManager.isActive, "PowerManager should start inactive")
	}

	func testActivate() {
		let result = powerManager.activate()
		XCTAssertTrue(result, "Activation should succeed")
		XCTAssertTrue(powerManager.isActive, "PowerManager should be active after activation")
	}

	func testActivateWhenAlreadyActive() {
		powerManager.activate()
		let result = powerManager.activate()
		XCTAssertTrue(result, "Activating when already active should return true")
		XCTAssertTrue(powerManager.isActive, "PowerManager should remain active")
	}

	func testDeactivate() {
		powerManager.activate()
		let result = powerManager.deactivate()
		XCTAssertTrue(result, "Deactivation should succeed")
		XCTAssertFalse(powerManager.isActive, "PowerManager should be inactive after deactivation")
	}

	func testDeactivateWhenAlreadyInactive() {
		let result = powerManager.deactivate()
		XCTAssertTrue(result, "Deactivating when already inactive should return true")
		XCTAssertFalse(powerManager.isActive, "PowerManager should remain inactive")
	}

	func testToggleFromInactive() {
		let newState = powerManager.toggle()
		XCTAssertTrue(newState, "Toggle from inactive should return true (now active)")
		XCTAssertTrue(powerManager.isActive, "PowerManager should be active after toggle")
	}

	func testToggleFromActive() {
		powerManager.activate()
		let newState = powerManager.toggle()
		XCTAssertFalse(newState, "Toggle from active should return false (now inactive)")
		XCTAssertFalse(powerManager.isActive, "PowerManager should be inactive after toggle")
	}

	func testMultipleToggles() {
		XCTAssertFalse(powerManager.isActive)

		powerManager.toggle()
		XCTAssertTrue(powerManager.isActive)

		powerManager.toggle()
		XCTAssertFalse(powerManager.isActive)

		powerManager.toggle()
		XCTAssertTrue(powerManager.isActive)

		powerManager.toggle()
		XCTAssertFalse(powerManager.isActive)
	}

	func testCustomInitialization() {
		let customManager = PowerManager(name: "CustomName", reason: "Custom reason")
		XCTAssertFalse(customManager.isActive)

		let result = customManager.activate()
		XCTAssertTrue(result)
		XCTAssertTrue(customManager.isActive)

		customManager.deactivate()
	}
}
