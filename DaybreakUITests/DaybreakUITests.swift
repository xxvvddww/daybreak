import XCTest

/// UI tests for the core journeys. The app launches with `-uitests` for a
/// clean, in-memory, pre-onboarding state.
final class DaybreakUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    private func launchApp() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["-uitests"]
        app.launch()
        return app
    }

    func testOnboardingLeadsToHome() {
        let app = launchApp()
        let getStarted = app.buttons["Get started"]
        XCTAssertTrue(getStarted.waitForExistence(timeout: 5))
        getStarted.tap()

        // The Today tab should be selectable in the tab bar.
        XCTAssertTrue(app.buttons["Today"].waitForExistence(timeout: 5))
    }

    func testNavigatesBetweenTabs() {
        let app = launchApp()
        let getStarted = app.buttons["Get started"]
        XCTAssertTrue(getStarted.waitForExistence(timeout: 5))
        getStarted.tap()

        app.buttons["Pay"].tap()
        XCTAssertTrue(app.staticTexts["Pay calculator"].waitForExistence(timeout: 5))

        app.buttons["Stats"].tap()
        XCTAssertTrue(app.staticTexts["Where you sit"].waitForExistence(timeout: 5))

        app.buttons["Setup"].tap()
        // FieldLabel uppercases its text, so the rendered label is "ANNUAL SALARY".
        XCTAssertTrue(app.staticTexts["ANNUAL SALARY"].waitForExistence(timeout: 5))
    }

    func testSetupShowsControls() {
        let app = launchApp()
        let getStarted = app.buttons["Get started"]
        XCTAssertTrue(getStarted.waitForExistence(timeout: 5))
        getStarted.tap()

        app.buttons["Setup"].tap()
        XCTAssertTrue(app.sliders["Annual salary"].waitForExistence(timeout: 5))
        // The Medicare levy toggle should be present.
        XCTAssertTrue(app.switches["Medicare levy"].exists)
    }
}
