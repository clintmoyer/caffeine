/*
Copyright 2024 Clint Moyer

This program is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free Software
Foundation, either version 3 of the License, or (at your option) any later
version.

This program is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with
this program. If not, see <https://www.gnu.org/licenses/>.
*/

import Cocoa
import IOKit.pwr_mgt

class CaffeineApp: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var assertionID: IOPMAssertionID = 0  // For sleep prevention
    var isActive = false  // Track the state of Caffeine

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        NSApp.setActivationPolicy(.prohibited)
        setupMenuBarIcon()
    }

    func setupMenuBarIcon() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        
        if let button = statusItem.button {
            button.image = NSImage(named: "inactive")  // Default to inactive icon

            // Create a custom button to handle user interaction
            let customView = CustomStatusButton(frame: button.bounds)
            customView.target = self
            button.addSubview(customView)
        }

        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quitApp), keyEquivalent: "q"))
        statusItem.menu = menu
    }

    @objc func toggleCaffeine() {
        if isActive {
            deactivateCaffeine()  // Deactivate if currently active
        } else {
            activateCaffeine()    // Activate if currently inactive
        }
        updateIcon()  // Update the icon to reflect the current state
    }

    func activateCaffeine() {
        let reasonForActivity = "Preventing sleep while Caffeine is active" as CFString
        let result = IOPMAssertionCreateWithName(kIOPMAssertionTypeNoDisplaySleep as CFString,
                                                 IOPMAssertionLevel(kIOPMAssertionLevelOn),
                                                 reasonForActivity,
                                                 &assertionID)
        if result != kIOReturnSuccess {
            print("Failed to create sleep assertion: \(result)")
            isActive = false  // Ensure state consistency
            NSAlert(error: NSError(domain: "", code: Int(result), userInfo: [NSLocalizedDescriptionKey: "Failed to prevent sleep"])).runModal()
        }
    }

    func deactivateCaffeine() {
        if isActive {
            IOPMAssertionRelease(assertionID)  // Release the assertion
            isActive = false  // Set inactive after deactivation
            print("Caffeine deactivated. Sleep allowed.")
        }
    }

    func updateIcon() {
        if let button = statusItem.button {
            if isActive {
                button.image = NSImage(named: "active")   // Active state icon
            } else {
                button.image = NSImage(named: "inactive") // Inactive state icon
            }
        }
    }

    @objc func quitApp() {
        deactivateCaffeine()  // Ensure sleep is allowed when quitting
        NSApplication.shared.terminate(self)
    }
}

class CustomStatusButton: NSView {
    var target: CaffeineApp?

    override func mouseDown(with event: NSEvent) {
        if event.type == .leftMouseDown {
            target?.toggleCaffeine()  // Toggle Caffeine on left-click
        }
    }

    override func rightMouseDown(with event: NSEvent) {
        if let statusItem = target?.statusItem {
            statusItem.menu?.popUp(positioning: nil, at: NSEvent.mouseLocation, in: nil)  // Show menu on right-click
        }
    }
}

let app = NSApplication.shared
let delegate = CaffeineApp()
app.delegate = delegate
app.run()

