//
//  OTPViewController.swift
//  PHR_Project
//
//  Created by Sushant Pulipati on 05/02/26.
//

import UIKit

class OTPViewController: UIViewController {

    @IBOutlet weak var otp1: UITextField!
    @IBOutlet weak var otp2: UITextField!
    @IBOutlet weak var otp3: UITextField!
    @IBOutlet weak var otp4: UITextField!

    /// Phone number passed from MobileNoViewController
    var phoneNumber: String = ""

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupOTPFields()
        setupTextFields()
    }

    // MARK: - OTP Field Setup

    private func setupOTPFields() {
        let fields = [otp1, otp2, otp3, otp4]
        for field in fields {
            field?.keyboardType = .numberPad
            field?.textAlignment = .center
            field?.delegate = self
        }
        otp1.becomeFirstResponder()
    }

    private func setupTextFields() {
        styleTextField(otp1)
        styleTextField(otp2)
        styleTextField(otp3)
        styleTextField(otp4)
    }

    private func styleTextField(_ textField: UITextField) {
        // This manually forces the rounding
        textField.layer.cornerRadius = 16
        textField.layer.masksToBounds = true

        textField.layer.borderWidth = 1.0
        textField.layer.borderColor = UIColor.systemGray5.cgColor

        let paddingView = UIView(
            frame: CGRect(x: 0, y: 0, width: 10, height: textField.frame.height)
        )
        textField.leftView = paddingView
        textField.leftViewMode = .always
    }

    // MARK: - Actions

    @IBAction func onVerifyClick(_ sender: Any) {
        // Validate that all OTP fields have a digit
        guard let d1 = otp1.text, !d1.isEmpty,
            let d2 = otp2.text, !d2.isEmpty,
            let d3 = otp3.text, !d3.isEmpty,
            let d4 = otp4.text, !d4.isEmpty
        else {
            showAlert(
                title: "Incomplete OTP",
                message: "Please enter all 4 digits."
            )
            return
        }

        // Prototyping: accept any 4-digit OTP — no real verification
        loginAndCheckProfile()
    }

    // MARK: - Auth Flow

    private func loginAndCheckProfile() {
        showLoader()

        AuthService.shared.login(phoneNumber: phoneNumber) {
            [weak self] success, errorMessage in
            guard let self = self else { return }

            if !success {
                self.dismissLoader {
                    self.showAlert(
                        title: "Login Failed",
                        message: errorMessage
                            ?? "Something went wrong. Please try again."
                    )
                }
                return
            }

            // Login succeeded — now check if user has a profile
            self.checkForExistingProfile()
        }
    }

    private func checkForExistingProfile() {
        APIService.shared.request(
            endpoint: "/profile",
            method: .get
        ) { [weak self] (result: Result<ProfileModel?, Error>) in
            guard let self = self else { return }

            switch result {
            case .success(let profile) where profile != nil:
                // Profile exists — save locally and go to main app
                self.dismissLoader {
                    ProfileService.shared.setProfile(to: profile!)
                    SceneDelegate.switchToMainApp()
                }

            case .success:
                // null profile — new user, continue through onboarding
                self.dismissLoader {
                    self.performSegue(
                        withIdentifier: "onOnboarding",
                        sender: nil
                    )
                }

            case .failure:
                // Network/decode error — fall back to onboarding
                self.dismissLoader {
                    self.performSegue(
                        withIdentifier: "onOnboarding",
                        sender: nil
                    )
                }
            }
        }
    }

    // MARK: - Helpers

    private func showLoader() {
        let alert = UIAlertController(
            title: nil,
            message: "Signing in...",
            preferredStyle: .alert
        )
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.startAnimating()
        alert.view.addSubview(indicator)
        NSLayoutConstraint.activate([
            indicator.centerYAnchor.constraint(
                equalTo: alert.view.centerYAnchor
            ),
            indicator.leadingAnchor.constraint(
                equalTo: alert.view.leadingAnchor,
                constant: 20
            ),
            alert.view.heightAnchor.constraint(
                greaterThanOrEqualToConstant: 80
            ),
        ])
        present(alert, animated: true)
    }

    private func dismissLoader(completion: (() -> Void)? = nil) {
        if let presented = presentedViewController as? UIAlertController,
            presented.title == nil
        {
            presented.dismiss(animated: true, completion: completion)
        } else {
            completion?()
        }
    }

}

// MARK: - UITextFieldDelegate (Auto-advance OTP fields)

extension OTPViewController: UITextFieldDelegate {

    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        // Allow backspace
        if string.isEmpty {
            textField.text = ""
            // Move to previous field on backspace
            switch textField {
            case otp2: otp1.becomeFirstResponder()
            case otp3: otp2.becomeFirstResponder()
            case otp4: otp3.becomeFirstResponder()
            default: break
            }
            return false
        }

        // Only allow single digit
        guard string.count == 1,
            string.rangeOfCharacter(from: .decimalDigits) != nil
        else {
            return false
        }

        textField.text = string

        // Auto-advance to next field
        switch textField {
        case otp1: otp2.becomeFirstResponder()
        case otp2: otp3.becomeFirstResponder()
        case otp3: otp4.becomeFirstResponder()
        case otp4: otp4.resignFirstResponder()
        default: break
        }

        return false
    }
}
