import UIKit

class FamilyPermissionsTableViewController: UITableViewController {

    // MARK: - Outlets
    @IBOutlet weak var nameDetailLabel: UILabel!
    @IBOutlet weak var contactDetailLabel: UILabel!

    var selectedContact: Contact?
    private var loadingAlert: UIAlertController?

    override func viewDidLoad() {
        super.viewDidLoad()

        if let contact = selectedContact {
            nameDetailLabel.text = contact.name
            contactDetailLabel.text = contact.phoneNum
        }
    }
    // MARK: - Actions
    @IBAction func tickButtonTapped(_ sender: UIBarButtonItem) {
        guard let contact = selectedContact else {
            dismiss(animated: true)
            return
        }
        showLoading(message: "Adding member...")
        addMember(for: contact)
    }

    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }

    private func addMember(for contact: Contact) {
        guard let familyId = FamilyService.shared.getCurrentFamilyId() else {
            hideLoading()
            showErrorAlert(message: "Please select a family first.")
            return
        }

        FamilyService.shared.addMember(
            familyId: familyId,
            phoneNumber: contact.phoneNum
        ) { [weak self] result in
            switch result {
            case .success:
                self?.hideLoading()
                self?.dismiss(animated: true)
            case .failure(let error):
                self?.hideLoading()
                if case APIError.httpError(let statusCode, _) = error,
                    statusCode == 404
                {
                    self?.showErrorAlert(
                        message:
                            "Given phone number doesn't have an account with us."
                    )
                } else {
                    self?.showErrorAlert(message: error.localizedDescription)
                }
            }
        }
    }

    private func showLoading(message: String) {
        let alert = UIAlertController(
            title: nil,
            message: message,
            preferredStyle: .alert
        )
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.startAnimating()
        alert.view.addSubview(indicator)

        navigationItem.rightBarButtonItem?.isEnabled = false
        navigationItem.leftBarButtonItem?.isEnabled = false

        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(
                equalTo: alert.view.centerXAnchor
            ),
            indicator.bottomAnchor.constraint(
                equalTo: alert.view.bottomAnchor,
                constant: -20
            ),
        ])

        present(alert, animated: true)
        loadingAlert = alert
    }

    private func hideLoading() {
        loadingAlert?.dismiss(animated: true)
        loadingAlert = nil
        navigationItem.rightBarButtonItem?.isEnabled = true
        navigationItem.leftBarButtonItem?.isEnabled = true
    }

    private func showErrorAlert(message: String) {
        let alert = UIAlertController(
            title: "Error",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

}
