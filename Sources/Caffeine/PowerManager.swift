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
import Foundation
import IOKit
import IOKit.pwr_mgt

// Manages power assertions to prevent the system from sleeping
public final class PowerManager {

	// The current power assertion ID, if active
	private var assertionID: IOPMAssertionID = IOPMAssertionID(0)

	// Whether the power assertion is currently active
	public private(set) var isActive: Bool = false

	// The name used for the power assertion
	private let assertionName: String

	// The reason for the power assertion
	private let assertionReason: String

	public init(name: String = "Caffeine", reason: String = "User requested to prevent system sleep") {
		self.assertionName = name
		self.assertionReason = reason
	}

	deinit {
		if isActive {
			deactivate()
		}
	}

	// Activates the power assertion to prevent system sleep
	// - Returns: true if activation was successful, false otherwise
	@discardableResult
	public func activate() -> Bool {
		guard !isActive else { return true }

		let properties: [String: Any] = [
			kIOPMAssertionTypeKey: kIOPMAssertionTypePreventUserIdleDisplaySleep,
			kIOPMAssertionNameKey: assertionName,
			kIOPMAssertionLevelKey: IOPMAssertionLevel(kIOPMAssertionLevelOn),
			kIOPMAssertionDetailsKey: assertionReason
		]

		let cfProperties = properties as CFDictionary
		var newAssertionID: IOPMAssertionID = IOPMAssertionID(0)

		let result = IOPMAssertionCreateWithProperties(cfProperties, &newAssertionID)

		if result == kIOReturnSuccess {
			assertionID = newAssertionID
			isActive = true
			return true
		}

		return false
	}

	// Deactivates the power assertion, allowing the system to sleep normally
	// - Returns: true if deactivation was successful, false otherwise
	@discardableResult
	public func deactivate() -> Bool {
		guard isActive else { return true }

		let result = IOPMAssertionRelease(assertionID)

		if result == kIOReturnSuccess {
			assertionID = IOPMAssertionID(0)
			isActive = false
			return true
		}

		return false
	}

	// Toggles the power assertion state
	// - Returns: The new active state after toggling
	@discardableResult
	public func toggle() -> Bool {
		if isActive {
			deactivate()
		} else {
			activate()
		}
		return isActive
	}
}
