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
        numberField.delegate = self
        numberField.keyboardType = .phonePad
    }

    @IBAction func onGetOtp(_ sender: Any) {
        guard let phone = numberField.text?.trimmingCharacters(in: .whitespaces),
              !phone.isEmpty else {
            showAlert(title: "Phone Number Required", message: "Please enter your phone number.")
            return
        }

        guard phone.count >= 10 else {
            showAlert(title: "Invalid Number", message: "Please enter a valid phone number (at least 10 digits).")
            return
        }

        performSegue(withIdentifier: "otpSegue", sender: phone)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "otpSegue",
           let otpVC = segue.destination as? OTPViewController,
           let phoneNumber = sender as? String {
            otpVC.phoneNumber = phoneNumber
        }
    }

    // MARK: - Helpers

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
