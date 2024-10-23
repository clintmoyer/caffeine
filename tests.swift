import XCTest

@testable import CaffeineApp // This assumes your app code is in `CaffeineApp.swift`

final class CaffeineAppTests: XCTestCase {
    var app: CaffeineApp!

    override func setUp() {
        super.setUp()
        app = CaffeineApp() // initialize your app
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

// To run the tests
XCTMain([testCase(CaffeineAppTests.allTests)])
