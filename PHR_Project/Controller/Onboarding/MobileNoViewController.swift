//
//  MobileNoViewController.swift
//  PHR_Project
//
//  Created by Sushant Pulipati on 03/02/26.
//

import UIKit

class MobileNoViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var numberField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        numberField.keyboardType = .phonePad
        setupTextField()
    }

    private func setupTextField() {
        numberField.delegate = self
        styleTextField(numberField)
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

    @IBAction func onGetOtp(_ sender: Any) {
        guard
            let phone = numberField.text?.trimmingCharacters(in: .whitespaces),
            !phone.isEmpty
        else {
            showAlert(
                title: "Phone Number Required",
                message: "Please enter your phone number."
            )
            return
        }

        guard phone.count >= 10 else {
            showAlert(
                title: "Invalid Number",
                message:
                    "Please enter a valid phone number (at least 10 digits)."
            )
            return
        }

        performSegue(withIdentifier: "otpSegue", sender: phone)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "otpSegue",
            let otpVC = segue.destination as? OTPViewController,
            let phoneNumber = sender as? String
        {
            otpVC.phoneNumber = phoneNumber
        }
    }

    // MARK: - Helpers

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
