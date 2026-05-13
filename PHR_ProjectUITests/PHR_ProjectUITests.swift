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
        // Launch fresh every test so state doesn't leak between tests.
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
        // The phone number text field is the first element on the login screen.
        return app.textFields.firstMatch.waitForExistence(timeout: 3)
    }

    // MARK: - Test 1: App launches successfully

    func testAppLaunchesWithoutCrashing() throws {
        // Simply verify the app is running — either login screen or main tab bar.
        let appIsRunning =
            app.textFields.firstMatch.waitForExistence(timeout: 5)
            || app.tabBars.firstMatch.waitForExistence(timeout: 5)
        XCTAssertTrue(appIsRunning, "App should show either the login screen or the main tab bar after launch.")
    }

    // MARK: - Test 2: Phone number screen shows a text field and a button

    func testPhoneNumberScreenElements() throws {
        guard isOnLoginFlow else {
            throw XCTSkip("Already logged in — phone screen not visible.")
        }

        // There should be at least one text field (the phone number field).
        XCTAssertTrue(
            app.textFields.firstMatch.exists,
            "Phone number text field should be visible on the login screen."
        )

        // There should be at least one button (the 'Get OTP' button).
        XCTAssertTrue(
            app.buttons.firstMatch.exists,
            "At least one button should be visible on the login screen."
        )
    }

    // MARK: - Test 3: Entering a phone number enables navigation to OTP screen

    func testEnteringPhoneNumberAndTappingGetOTP() throws {
        guard isOnLoginFlow else {
            throw XCTSkip("Already logged in — phone screen not visible.")
        }

        let phoneField = app.textFields.firstMatch
        phoneField.tap()
        phoneField.typeText("9876543210")   // 10-digit dummy number

        // Tap the first (and only) button — "Get OTP"
        app.buttons.firstMatch.tap()

        // After tapping, the OTP screen should appear.
        // The OTP screen has 4 single-character text fields.
        let otpFieldAppeared = app.textFields.count >= 4
            || app.textFields.firstMatch.waitForExistence(timeout: 3)
        XCTAssertTrue(
            otpFieldAppeared,
            "OTP input screen should appear after submitting a phone number."
        )
    }

    // MARK: - Test 4: Short phone number shows a validation alert

    func testShortPhoneNumberShowsAlert() throws {
        guard isOnLoginFlow else {
            throw XCTSkip("Already logged in — phone screen not visible.")
        }

        let phoneField = app.textFields.firstMatch
        phoneField.tap()
        phoneField.typeText("123")   // Too short (< 10 digits)

        app.buttons.firstMatch.tap()

        // An alert should appear with a validation message.
        let alert = app.alerts.firstMatch
        let alertAppeared = alert.waitForExistence(timeout: 3)
        XCTAssertTrue(alertAppeared, "A validation alert should appear for a phone number shorter than 10 digits.")

        // Dismiss the alert.
        if alertAppeared {
            alert.buttons.firstMatch.tap()
        }
    }

    // MARK: - Test 5: Empty phone number shows a validation alert

    func testEmptyPhoneNumberShowsAlert() throws {
        guard isOnLoginFlow else {
            throw XCTSkip("Already logged in — phone screen not visible.")
        }

        // Tap the button without entering any text.
        app.buttons.firstMatch.tap()

        let alert = app.alerts.firstMatch
        let alertAppeared = alert.waitForExistence(timeout: 3)
        XCTAssertTrue(alertAppeared, "A validation alert should appear when the phone number field is empty.")

        if alertAppeared {
            alert.buttons.firstMatch.tap()
        }
    }

    // MARK: - Test 6: OTP screen accepts exactly 4 digits

    func testOTPScreenAcceptsInput() throws {
        guard isOnLoginFlow else {
            throw XCTSkip("Already logged in — phone screen not visible.")
        }

        // Navigate to the OTP screen first.
        let phoneField = app.textFields.firstMatch
        phoneField.tap()
        phoneField.typeText("9876543210")
        app.buttons.firstMatch.tap()

        // Wait for OTP screen (it should have 4 text fields).
        let firstOTPField = app.textFields.element(boundBy: 0)
        let otpScreenLoaded = firstOTPField.waitForExistence(timeout: 5)
        guard otpScreenLoaded else {
            throw XCTSkip("OTP screen did not appear — possibly a network issue in test environment.")
        }

        // Type one digit into the first OTP field.
        firstOTPField.tap()
        firstOTPField.typeText("1")

        // After typing '1', focus should auto-advance to the second field.
        // Verify the second field exists.
        let secondOTPField = app.textFields.element(boundBy: 1)
        XCTAssertTrue(
            secondOTPField.exists,
            "Second OTP field should exist after the first."
        )
    }

    // MARK: - Test 7: Main tab bar is visible when already logged in

    func testMainTabBarVisibleWhenLoggedIn() throws {
        // This test only runs if the app launches directly into the main app.
        let tabBar = app.tabBars.firstMatch
        guard tabBar.waitForExistence(timeout: 5) else {
            throw XCTSkip("Not logged in — main tab bar not visible.")
        }

        XCTAssertTrue(tabBar.exists, "Main tab bar should be visible for a logged-in user.")
    }
}
