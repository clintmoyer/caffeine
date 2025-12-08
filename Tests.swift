import XCTest

@testable import caffeine

final class CaffeineAppTests: XCTestCase {
    var app: CaffeineApp!

    override func setUp() {
        super.setUp()
        app = CaffeineApp()
    }

    override func tearDown() {
        app = nil
        super.tearDown()
    }

    func testActivateCaffeine() {
        app.activateCaffeine()
        XCTAssertTrue(app.isActive, "Caffeine should be active after activation.")
    }

    func testDeactivateCaffeine() {
        app.activateCaffeine()
        app.deactivateCaffeine()
        XCTAssertFalse(app.isActive, "Caffeine should be inactive after deactivation.")
    }

    func testToggleCaffeine() {
        app.toggleCaffeine()
        XCTAssertTrue(app.isActive, "Caffeine should be active after toggle.")
        app.toggleCaffeine()
        XCTAssertFalse(app.isActive, "Caffeine should be inactive after another toggle.")
    }
}

XCTMain([testCase(CaffeineAppTests.allTests)])

