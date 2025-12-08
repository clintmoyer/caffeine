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
import UserNotifications

protocol PowerManager {
    func createAssertion(withProperties properties: CFDictionary, assertionID: UnsafeMutablePointer<IOPMAssertionID>) -> IOReturn
    func releaseAssertion(_ assertionID: IOPMAssertionID) -> IOReturn
}

class RealPowerManager: PowerManager {
    func createAssertion(withProperties properties: CFDictionary, assertionID: UnsafeMutablePointer<IOPMAssertionID>) -> IOReturn {
        IOPMAssertionCreateWithProperties(properties, assertionID)
    }

    func releaseAssertion(_ assertionID: IOPMAssertionID) -> IOReturn {
        IOPMAssertionRelease(assertionID)
    }
}

@MainActor
class CaffeineApp: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    var assertionID: IOPMAssertionID = 0
    var isActive = false {
        didSet {
            updateUI()
        }
    }

    let activeIcon = NSImage(systemSymbolName: "cup.and.saucer.fill", accessibilityDescription: "Caffeine Active")
    let inactiveIcon = NSImage(systemSymbolName: "cup.and.saucer", accessibilityDescription: "Caffeine Inactive")

    var powerManager: PowerManager

    override init() {
        self.powerManager = RealPowerManager()
        super.init()
    }

    init(powerManager: PowerManager = RealPowerManager()) {
        self.powerManager = powerManager
        super.init()
    }

    func applicationDidFinishLaunching(_: Notification) {
        NSApp.setActivationPolicy(.accessory) // Better than .prohibited
        setupMenuBar()

        // Request notification authorization
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert]) { _, error in
            if let error = error {
                print("Error requesting notification authorization: \(error.localizedDescription)")
            }
        }
    }

    func applicationWillTerminate(_: Notification) {
        deactivate() // Clean up on quit
    }

    private func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        guard let button = statusItem.button else {
            fatalError("Failed to create status bar button")
        }

        // Configure button
        button.image = inactiveIcon
        button.image?.isTemplate = true // Adapt to menu bar theme
        button.toolTip = "Caffeine - Click to toggle"
        button.target = self
        button.action = #selector(statusBarButtonClicked(_:))
        button.sendAction(on: [.leftMouseUp, .rightMouseUp])

        updateMenu()
    }

    @objc private func statusBarButtonClicked(_: NSStatusBarButton) {
        guard let event = NSApp.currentEvent else { return }

        if event.type == .rightMouseUp {
            showMenu()
        } else {
            toggle()
        }
    }

    private func showMenu() {
        updateMenu()
        statusItem.menu = createMenu()
        statusItem.button?.performClick(nil) // Show menu
        statusItem.menu = nil // Remove menu so left-click still works
    }

    func createMenu() -> NSMenu {
        let menu = NSMenu()

        // Toggle item with checkmark
        let toggleItem = NSMenuItem(
            title: isActive ? "Deactivate" : "Activate",
            action: #selector(toggle),
            keyEquivalent: ""
        )
        toggleItem.state = isActive ? .on : .off
        menu.addItem(toggleItem)

        menu.addItem(NSMenuItem.separator())

        // Status display
        let statusItem = NSMenuItem(
            title: isActive ? "⚡ Preventing Sleep" : "💤 Sleep Allowed",
            action: nil,
            keyEquivalent: ""
        )
        statusItem.isEnabled = false
        menu.addItem(statusItem)

        menu.addItem(NSMenuItem.separator())

        // Quit
        menu.addItem(
            NSMenuItem(
                title: "Quit Caffeine",
                action: #selector(quitApp),
                keyEquivalent: "q"
            )
        )

        return menu
    }

    private func updateMenu() {
        // Menu is created on-demand, so just update UI
        updateUI()
    }

    @objc func toggle() {
        if isActive {
            deactivate()
        } else {
            activate()
        }
    }

    func activate() {
        let properties: [CFString: Any] = [
            kIOPMAssertionTypeKey as CFString: kIOPMAssertionTypeNoDisplaySleep as CFString,
            kIOPMAssertionLevelKey as CFString: kIOPMAssertionLevelOn,
            kIOPMAssertionNameKey as CFString: "Caffeine: Preventing display sleep" as CFString
        ]

        let result = powerManager.createAssertion(withProperties: properties as CFDictionary, assertionID: &assertionID)

        if result == kIOReturnSuccess {
            isActive = true
            showNotification(title: "Caffeine Activated", body: "Display will not sleep")
        } else {
            showError(message: "Failed to prevent sleep (error: \(result))")
        }
    }

    func deactivate() {
        guard isActive else { return }

        let result = powerManager.releaseAssertion(assertionID)

        if result == kIOReturnSuccess || result == kIOReturnNotFound {
            isActive = false
            assertionID = 0
            showNotification(title: "Caffeine Deactivated", body: "Normal sleep behavior restored")
        } else {
            showError(message: "Failed to release sleep assertion (error: \(result))")
        }
    }

    func updateUI() {
        guard let button = statusItem.button else { return }

        button.image = isActive ? activeIcon : inactiveIcon
        button.toolTip = isActive ? "Caffeine Active - Click to deactivate" : "Caffeine Inactive - Click to activate"

        // Subtle animation on state change
        button.animator().alphaValue = 0.5
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            button.animator().alphaValue = 1.0
        }
    }

    private func showNotification(title: String, body: String) {
        let center = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = nil

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)

        center.add(request) { error in
            if let error = error {
                print("Error delivering notification: \(error.localizedDescription)")
            }
        }
    }

    private func showError(message: String) {
        let alert = NSAlert()
        alert.messageText = "Caffeine Error"
        alert.informativeText = message
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }

    @objc private func quitApp() {
        NSApplication.shared.terminate(self)
    }
}

// MARK: - App Entry Point

let app = NSApplication.shared
let delegate = CaffeineApp()
app.delegate = delegate
app.run()
