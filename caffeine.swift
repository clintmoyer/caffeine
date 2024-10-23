/*
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

class CaffeineApp: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var isActive = false  // New property to track activation status

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        setupMenuBarIcon()
    }

    func setupMenuBarIcon() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem.button {
            button.image = NSImage(named: "inactive")  // Default icon

            // Create custom button and assign action for toggling Caffeine
            let customView = CustomStatusButton(frame: button.bounds)
            customView.target = self
            button.addSubview(customView)
        }

        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quitApp), keyEquivalent: "q"))
        statusItem.menu = menu
    }

    @objc func toggleCaffeine() {
        isActive.toggle()  // Toggle the active state
        updateIcon()       // Update icon based on the current state
    }

    func updateIcon() {
        if let button = statusItem.button {
            if isActive {
                button.image = NSImage(named: "active")   // Active icon
            } else {
                button.image = NSImage(named: "inactive") // Inactive icon
            }
        }
    }

    @objc func quitApp() {
        NSApplication.shared.terminate(self)
    }
}

class CustomStatusButton: NSView {
    var target: CaffeineApp?

    override func mouseDown(with event: NSEvent) {
        if event.type == .leftMouseDown {
            target?.toggleCaffeine()  // Toggle state on left-click
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

