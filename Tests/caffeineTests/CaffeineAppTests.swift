import Testing
import Cocoa
import IOKit.pwr_mgt
@testable import caffeine

class MockPowerManager: PowerManager {
    var createAssertionCalled = false
    var releaseAssertionCalled = false
    var createAssertionResult: IOReturn = kIOReturnSuccess
    var releaseAssertionResult: IOReturn = kIOReturnSuccess
    var lastAssertionProperties: CFDictionary?

    func createAssertion(withProperties properties: CFDictionary, assertionID: UnsafeMutablePointer<IOPMAssertionID>) -> IOReturn {
        createAssertionCalled = true
        lastAssertionProperties = properties
        assertionID.pointee = 12345
        return createAssertionResult
    }

    func releaseAssertion(_ assertionID: IOPMAssertionID) -> IOReturn {
        releaseAssertionCalled = true
        return releaseAssertionResult
    }
}

final class MockNotificationManager: NotificationManager, @unchecked Sendable {
    var notifications: [(title: String, body: String)] = []

    func showNotification(title: String, body: String) {
        notifications.append((title: title, body: body))
    }
}

@MainActor
@Suite("CaffeineApp Tests")
struct CaffeineAppTests {

    @Test("Initial state is inactive")
    func initialStateIsInactive() {
        let mockPowerManager = MockPowerManager()
        let mockNotificationManager = MockNotificationManager()
        let app = CaffeineApp(powerManager: mockPowerManager, notificationManager: mockNotificationManager)

        #expect(app.isActive == false)
        #expect(app.assertionID == 0)
    }

    @Test("Activate sets isActive to true on success")
    func activateSetsIsActiveOnSuccess() {
        let mockPowerManager = MockPowerManager()
        let mockNotificationManager = MockNotificationManager()
        mockPowerManager.createAssertionResult = kIOReturnSuccess
        let app = CaffeineApp(powerManager: mockPowerManager, notificationManager: mockNotificationManager)
        app.statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        app.activate()

        #expect(app.isActive == true)
        #expect(mockPowerManager.createAssertionCalled == true)
        #expect(app.assertionID == 12345)
    }

    @Test("Activate does not set isActive on failure")
    func activateDoesNotSetIsActiveOnFailure() {
        let mockPowerManager = MockPowerManager()
        let mockNotificationManager = MockNotificationManager()
        mockPowerManager.createAssertionResult = kIOReturnError
        let app = CaffeineApp(powerManager: mockPowerManager, notificationManager: mockNotificationManager)
        app.statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        app.activate()

        #expect(app.isActive == false)
        #expect(mockPowerManager.createAssertionCalled == true)
    }

    @Test("Deactivate sets isActive to false on success")
    func deactivateSetsIsActiveOnSuccess() {
        let mockPowerManager = MockPowerManager()
        let mockNotificationManager = MockNotificationManager()
        mockPowerManager.createAssertionResult = kIOReturnSuccess
        mockPowerManager.releaseAssertionResult = kIOReturnSuccess
        let app = CaffeineApp(powerManager: mockPowerManager, notificationManager: mockNotificationManager)
        app.statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        app.activate()
        #expect(app.isActive == true)

        app.deactivate()

        #expect(app.isActive == false)
        #expect(mockPowerManager.releaseAssertionCalled == true)
        #expect(app.assertionID == 0)
    }

    @Test("Deactivate handles kIOReturnNotFound as success")
    func deactivateHandlesNotFoundAsSuccess() {
        let mockPowerManager = MockPowerManager()
        let mockNotificationManager = MockNotificationManager()
        mockPowerManager.createAssertionResult = kIOReturnSuccess
        mockPowerManager.releaseAssertionResult = kIOReturnNotFound
        let app = CaffeineApp(powerManager: mockPowerManager, notificationManager: mockNotificationManager)
        app.statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        app.activate()
        app.deactivate()

        #expect(app.isActive == false)
        #expect(app.assertionID == 0)
    }

    @Test("Deactivate does nothing when already inactive")
    func deactivateDoesNothingWhenInactive() {
        let mockPowerManager = MockPowerManager()
        let mockNotificationManager = MockNotificationManager()
        let app = CaffeineApp(powerManager: mockPowerManager, notificationManager: mockNotificationManager)
        app.statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        app.deactivate()

        #expect(app.isActive == false)
        #expect(mockPowerManager.releaseAssertionCalled == false)
    }

    @Test("Toggle activates when inactive")
    func toggleActivatesWhenInactive() {
        let mockPowerManager = MockPowerManager()
        let mockNotificationManager = MockNotificationManager()
        mockPowerManager.createAssertionResult = kIOReturnSuccess
        let app = CaffeineApp(powerManager: mockPowerManager, notificationManager: mockNotificationManager)
        app.statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        #expect(app.isActive == false)

        app.toggle()

        #expect(app.isActive == true)
    }

    @Test("Toggle deactivates when active")
    func toggleDeactivatesWhenActive() {
        let mockPowerManager = MockPowerManager()
        let mockNotificationManager = MockNotificationManager()
        mockPowerManager.createAssertionResult = kIOReturnSuccess
        mockPowerManager.releaseAssertionResult = kIOReturnSuccess
        let app = CaffeineApp(powerManager: mockPowerManager, notificationManager: mockNotificationManager)
        app.statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        app.activate()
        #expect(app.isActive == true)

        app.toggle()

        #expect(app.isActive == false)
    }

    @Test("CreateMenu returns menu with correct items")
    func createMenuReturnsCorrectItems() {
        let mockPowerManager = MockPowerManager()
        let mockNotificationManager = MockNotificationManager()
        let app = CaffeineApp(powerManager: mockPowerManager, notificationManager: mockNotificationManager)
        app.statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        let menu = app.createMenu()

        #expect(menu.items.count == 5)
        #expect(menu.items[0].title == "Activate")
        #expect(menu.items[0].state == .off)
        #expect(menu.items[2].title == "💤 Sleep Allowed")
        #expect(menu.items[4].title == "Quit Caffeine")
    }

    @Test("CreateMenu shows active state correctly")
    func createMenuShowsActiveState() {
        let mockPowerManager = MockPowerManager()
        let mockNotificationManager = MockNotificationManager()
        mockPowerManager.createAssertionResult = kIOReturnSuccess
        let app = CaffeineApp(powerManager: mockPowerManager, notificationManager: mockNotificationManager)
        app.statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        app.activate()
        let menu = app.createMenu()

        #expect(menu.items[0].title == "Deactivate")
        #expect(menu.items[0].state == .on)
        #expect(menu.items[2].title == "⚡ Preventing Sleep")
    }

    @Test("Icons are loaded correctly")
    func iconsAreLoadedCorrectly() {
        let mockPowerManager = MockPowerManager()
        let mockNotificationManager = MockNotificationManager()
        let app = CaffeineApp(powerManager: mockPowerManager, notificationManager: mockNotificationManager)

        #expect(app.activeIcon != nil)
        #expect(app.inactiveIcon != nil)
    }

    @Test("SetupMenuBar creates status item")
    func setupMenuBarCreatesStatusItem() {
        let mockPowerManager = MockPowerManager()
        let mockNotificationManager = MockNotificationManager()
        let app = CaffeineApp(powerManager: mockPowerManager, notificationManager: mockNotificationManager)

        app.setupMenuBar()

        #expect(app.statusItem != nil)
        #expect(app.statusItem.button != nil)
        #expect(app.statusItem.button?.image == app.inactiveIcon)
    }

    @Test("UpdateUI changes icon based on state")
    func updateUIChangesIcon() {
        let mockPowerManager = MockPowerManager()
        let mockNotificationManager = MockNotificationManager()
        mockPowerManager.createAssertionResult = kIOReturnSuccess
        let app = CaffeineApp(powerManager: mockPowerManager, notificationManager: mockNotificationManager)
        app.statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        app.statusItem.button?.image = app.inactiveIcon

        #expect(app.statusItem.button?.image == app.inactiveIcon)

        app.activate()

        #expect(app.statusItem.button?.image == app.activeIcon)
    }

    @Test("UpdateUI changes tooltip based on state")
    func updateUIChangesTooltip() {
        let mockPowerManager = MockPowerManager()
        let mockNotificationManager = MockNotificationManager()
        mockPowerManager.createAssertionResult = kIOReturnSuccess
        let app = CaffeineApp(powerManager: mockPowerManager, notificationManager: mockNotificationManager)
        app.statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        app.statusItem.button?.toolTip = "Caffeine Inactive - Click to activate"

        app.activate()

        #expect(app.statusItem.button?.toolTip == "Caffeine Active - Click to deactivate")
    }

    @Test("Default init uses RealPowerManager")
    func defaultInitUsesRealPowerManager() {
        let app = CaffeineApp()

        #expect(app.powerManager is RealPowerManager)
        #expect(app.notificationManager is RealNotificationManager)
    }

    @Test("Assertion properties are correct")
    func assertionPropertiesAreCorrect() {
        let mockPowerManager = MockPowerManager()
        let mockNotificationManager = MockNotificationManager()
        mockPowerManager.createAssertionResult = kIOReturnSuccess
        let app = CaffeineApp(powerManager: mockPowerManager, notificationManager: mockNotificationManager)
        app.statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        app.activate()

        #expect(mockPowerManager.lastAssertionProperties != nil)

        if let props = mockPowerManager.lastAssertionProperties as? [CFString: Any] {
            let name = props[kIOPMAssertionNameKey as CFString] as? String
            #expect(name == "Caffeine: Preventing display sleep")
        }
    }
}
