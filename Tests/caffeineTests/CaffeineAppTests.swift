import XCTest
import Cocoa
import IOKit.pwr_mgt
import UserNotifications

@testable import caffeine

class MockPowerManager: PowerManager {
    var createCalled = false
    var releaseCalled = false
    var createResult: IOReturn = kIOReturnSuccess
    var releaseResult: IOReturn = kIOReturnSuccess
    var createdAssertionID: IOPMAssertionID = 1

    func createAssertion(withProperties properties: CFDictionary, assertionID: UnsafeMutablePointer<IOPMAssertionID>) -> IOReturn {
        createCalled = true
        assertionID.pointee = createdAssertionID
        return createResult
    }

    func releaseAssertion(_ assertionID: IOPMAssertionID) -> IOReturn {
        releaseCalled = true
        return releaseResult
    }
}

class CaffeineAppTests: XCTestCase {
    var sut: CaffeineApp!
    var mockPowerManager: MockPowerManager!

    @MainActor
    override func setUp() {
        super.setUp()
        mockPowerManager = MockPowerManager()
        sut = CaffeineApp(powerManager: mockPowerManager)
    }

    @MainActor
    override func tearDown() {
        sut = nil
        mockPowerManager = nil
        super.tearDown()
    }

    @MainActor
    func testInitialState() {
        XCTAssertFalse(sut.isActive)
        XCTAssertEqual(sut.assertionID, 0)
    }

    @MainActor
    func testActivate_Success_SetsActiveAndAssertionID() {
        sut.activate()

        XCTAssertTrue(mockPowerManager.createCalled)
        XCTAssertTrue(sut.isActive)
        XCTAssertEqual(sut.assertionID, mockPowerManager.createdAssertionID)
    }

    @MainActor
    func testActivate_Failure_DoesNotSetActive() {
        mockPowerManager.createResult = kIOReturnError

        sut.activate()

        XCTAssertTrue(mockPowerManager.createCalled)
        XCTAssertFalse(sut.isActive)
        XCTAssertEqual(sut.assertionID, 0)
    }

    @MainActor
    func testDeactivate_Success_WhenActive_ResetsState() {
        sut.activate() // Precondition: active

        sut.deactivate()

        XCTAssertTrue(mockPowerManager.releaseCalled)
        XCTAssertFalse(sut.isActive)
        XCTAssertEqual(sut.assertionID, 0)
    }

    @MainActor
    func testDeactivate_Failure_WhenActive_KeepsActiveState() {
        sut.activate() // Precondition: active
        mockPowerManager.releaseResult = kIOReturnError // Not success or notFound

        sut.deactivate()

        XCTAssertTrue(mockPowerManager.releaseCalled)
        XCTAssertTrue(sut.isActive)
        XCTAssertEqual(sut.assertionID, mockPowerManager.createdAssertionID)
    }

    @MainActor
    func testDeactivate_WhenInactive_DoesNothing() {
        sut.deactivate()

        XCTAssertFalse(mockPowerManager.releaseCalled)
        XCTAssertFalse(sut.isActive)
        XCTAssertEqual(sut.assertionID, 0)
    }

    @MainActor
    func testToggle_FromInactiveToActive() {
        XCTAssertFalse(sut.isActive)

        sut.toggle()

        XCTAssertTrue(mockPowerManager.createCalled)
        XCTAssertTrue(sut.isActive)
    }

    @MainActor
    func testToggle_FromActiveToInactive() {
        sut.activate() // Precondition: active
        XCTAssertTrue(sut.isActive)

        sut.toggle()

        XCTAssertTrue(mockPowerManager.releaseCalled)
        XCTAssertFalse(sut.isActive)
    }

    @MainActor
    func testCreateMenu_WhenInactive() {
        let menu = sut.createMenu()

        XCTAssertEqual(menu.numberOfItems, 5) // toggle, sep, status, sep, quit

        let toggleItem = menu.item(at: 0)!
        XCTAssertEqual(toggleItem.title, "Activate")
        XCTAssertEqual(toggleItem.state, .off)
        XCTAssertEqual(toggleItem.action, #selector(CaffeineApp.toggle))

        let statusItem = menu.item(at: 2)!
        XCTAssertEqual(statusItem.title, "💤 Sleep Allowed")
        XCTAssertFalse(statusItem.isEnabled)

        let quitItem = menu.item(at: 4)!
        XCTAssertEqual(quitItem.title, "Quit Caffeine")
        XCTAssertEqual(quitItem.keyEquivalent, "q")
    }

    @MainActor
    func testCreateMenu_WhenActive() {
        sut.activate() // Precondition: active

        let menu = sut.createMenu()

        XCTAssertEqual(menu.numberOfItems, 5)

        let toggleItem = menu.item(at: 0)!
        XCTAssertEqual(toggleItem.title, "Deactivate")
        XCTAssertEqual(toggleItem.state, .on)

        let statusItem = menu.item(at: 2)!
        XCTAssertEqual(statusItem.title, "⚡ Preventing Sleep")
    }

    @MainActor
    func testUpdateUI_WhenActive_SetsActiveIconAndTooltip() {
        sut.setupMenuBar() // Need to initialize statusItem (assume setupMenuBar is called in tests if needed)
        sut.isActive = true // Triggers updateUI via didSet

        let button = sut.statusItem.button!
        XCTAssertEqual(button.image, sut.activeIcon)
        XCTAssertEqual(button.toolTip, "Caffeine Active - Click to deactivate")
    }

    @MainActor
    func testUpdateUI_WhenInactive_SetsInactiveIconAndTooltip() {
        sut.setupMenuBar()
        sut.isActive = false

        let button = sut.statusItem.button!
        XCTAssertEqual(button.image, sut.inactiveIcon)
        XCTAssertEqual(button.toolTip, "Caffeine Inactive - Click to activate")
    }
}
