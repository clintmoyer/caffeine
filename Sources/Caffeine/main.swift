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

// Configure the app as a menu bar only application (no dock icon)
let app = NSApplication.shared
app.setActivationPolicy(.accessory)

// Set up the app delegate
let delegate = AppDelegate()
app.delegate = delegate

// Run the application
app.run()
