import XCTest
@testable import caffeine

final class CaffeineTests: XCTestCase {
    var menuBarManager: MenuBarManager!

    override func setUpWithError() throws {
        super.setUp()
        menuBarManager = MenuBarManager()
    }

    override func tearDownWithError() throws {
        menuBarManager = nil
        super.tearDown()
    }

    func testMenuBarManagerInitialization() throws {
        XCTAssertNotNil(menuBarManager, "MenuBarManager should be initialized")
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
        // Simulate activating the caffeinate process
        menuBarManager.startCaffeinate()
        menuBarManager.updateMenuBarIcon()

        // Simulate deactivating the caffeinate process
        menuBarManager.stopCaffeinate()
        menuBarManager.updateMenuBarIcon()
    }
}

