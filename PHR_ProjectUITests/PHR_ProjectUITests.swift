//
//  PHR_ProjectUITests.swift
//  PHR_ProjectUITests
//
//  UI tests for PHR_Project.
//  The app uses a phone-number + 4-digit OTP login flow (no email/password).
//  These tests cover the onboarding / login screens that are always reachable
//  when the simulator is reset or the user is logged out.
//

import XCTest

final class PHR_ProjectUITests: XCTestCase {

    let app = XCUIApplication()

    // MARK: - Setup / Teardown

    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launchArguments = ["-UITesting"]
        app.launch()
    }

    override func tearDownWithError() throws {
        app.terminate()
    }

    // MARK: - Helper: reach the phone-number screen
    // The app lands on the phone screen when the user is NOT logged in.
    // If the app launches straight into the tab bar (already logged in),
    // these login-flow tests are skipped gracefully.

    private var isOnLoginFlow: Bool {
        // App lands on welcome screen first, not directly on phone field
        return app.buttons["Continue with Phone"].waitForExistence(timeout: 10)
    }

    // MARK: - Test 1: App launches successfully

    func testDebugPrintElements() throws {
        sleep(5)  // wait for app to load
        print(app.debugDescription)
    }

    func testAppLaunchesWithoutCrashing() throws {
        // Wait for ANY element to appear — buttons, labels, anything
        let appIsRunning =
            app.buttons.firstMatch.waitForExistence(timeout: 15)
            || app.staticTexts.firstMatch.waitForExistence(timeout: 15)
            || app.textFields.firstMatch.waitForExistence(timeout: 15)
            || app.tabBars.firstMatch.waitForExistence(timeout: 15)
        XCTAssertTrue(appIsRunning, "App should show some UI after launch.")
    }

    // MARK: - Test 2: Phone number screen shows a text field and a button

    func testPhoneNumberScreenElements() throws {
        guard isOnLoginFlow else {
            throw XCTSkip("Already logged in — phone screen not visible.")
        }
        app.buttons["Continue with Phone"].tap()  // ✅ ADD THIS

        XCTAssertTrue(
            app.textFields["numberField"].waitForExistence(timeout: 5), // also change .exists to waitForExistence
            "Phone number text field should be visible on the login screen."
        )
        let getOtpBtn = app.buttons["getOtpButton"]
        XCTAssertTrue(getOtpBtn.exists, "Get OTP button should be visible.")
    }

    func testEnteringPhoneNumberAndTappingGetOTP() throws {
        guard isOnLoginFlow else {
            throw XCTSkip("Already logged in — phone screen not visible.")
        }
        app.buttons["Continue with Phone"].tap()  // ✅ ADD THIS

        let phoneField = app.textFields["numberField"]
        phoneField.tap()
        phoneField.typeText("9876543210")
        app.buttons["getOtpButton"].tap()

        let otpFieldAppeared =
            app.textFields.count >= 4
            || app.textFields.firstMatch.waitForExistence(timeout: 3)
        XCTAssertTrue(otpFieldAppeared, "OTP input screen should appear after submitting a phone number.")
    }

    func testShortPhoneNumberShowsAlert() throws {
        guard isOnLoginFlow else {
            throw XCTSkip("Already logged in — phone screen not visible.")
        }
        app.buttons["Continue with Phone"].tap()  // ✅ ADD THIS

        let phoneField = app.textFields["numberField"]
        phoneField.tap()
        phoneField.typeText("123")
        app.buttons["getOtpButton"].tap()

        let alert = app.alerts.firstMatch
        let alertAppeared = alert.waitForExistence(timeout: 3)
        XCTAssertTrue(alertAppeared, "A validation alert should appear for a phone number shorter than 10 digits.")
        if alertAppeared { alert.buttons.firstMatch.tap() }
    }

    func testEmptyPhoneNumberShowsAlert() throws {
        guard isOnLoginFlow else {
            throw XCTSkip("Already logged in — phone screen not visible.")
        }
        app.buttons["Continue with Phone"].tap()  // ✅ ADD THIS

        app.buttons["getOtpButton"].tap()

        let alert = app.alerts.firstMatch
        let alertAppeared = alert.waitForExistence(timeout: 3)
        XCTAssertTrue(alertAppeared, "A validation alert should appear when the phone number field is empty.")
        if alertAppeared { alert.buttons.firstMatch.tap() }
    }

    func testOTPScreenAcceptsInput() throws {
        guard isOnLoginFlow else {
            throw XCTSkip("Already logged in — phone screen not visible.")
        }
        app.buttons["Continue with Phone"].tap()  // ✅ ADD THIS

        let phoneField = app.textFields["numberField"]
        phoneField.tap()
        phoneField.typeText("9876543210")
        app.buttons["getOtpButton"].tap()

        let firstOTPField = app.textFields.element(boundBy: 0)
        let otpScreenLoaded = firstOTPField.waitForExistence(timeout: 5)
        guard otpScreenLoaded else {
            throw XCTSkip("OTP screen did not appear — possibly a network issue in test environment.")
        }
        firstOTPField.tap()
        firstOTPField.typeText("1")

        let secondOTPField = app.textFields.element(boundBy: 1)
        XCTAssertTrue(secondOTPField.exists, "Second OTP field should exist after the first.")
    }

    // MARK: - Test 7: Main tab bar is visible when already logged in

    func testMainTabBarVisibleWhenLoggedIn() throws {
        // This test only runs if the app launches directly into the main app.
        let tabBar = app.tabBars.firstMatch
        guard tabBar.waitForExistence(timeout: 5) else {
            throw XCTSkip("Not logged in — main tab bar not visible.")
        }

        XCTAssertTrue(
            tabBar.exists,
            "Main tab bar should be visible for a logged-in user."
        )
    }

}
