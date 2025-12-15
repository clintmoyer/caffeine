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

// Application delegate for the Caffeine menu bar app
public final class AppDelegate: NSObject, NSApplicationDelegate {

	private var powerManager: PowerManager!
	private var statusBarController: StatusBarController!

	public func applicationDidFinishLaunching(_ notification: Notification) {
		powerManager = PowerManager()
		statusBarController = StatusBarController(powerManager: powerManager)
		statusBarController.setup()
	}

	public func applicationWillTerminate(_ notification: Notification) {
		powerManager.deactivate()
	}
}
