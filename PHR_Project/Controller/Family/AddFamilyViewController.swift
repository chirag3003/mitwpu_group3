import UIKit

class AddFamilyViewController: UIViewController, UITableViewDataSource,
    UITableViewDelegate, UISearchBarDelegate
{

    private var contacts: [Contact] = []

    // MARK: - Outlets

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.keyboardDismissMode = .onDrag
        searchBar.delegate = self

        setupHideKeyboardOnTap()
        setupKeyboardObservers()
        fetchContacts()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Keyboard Handling

    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    // Keyboard hide/show methods

    @objc private func keyboardWillShow(notification: NSNotification) {
        guard
            let keyboardFrame = notification.userInfo?[
                UIResponder.keyboardFrameEndUserInfoKey
            ] as? CGRect
        else { return }
        let keyboardHeight = keyboardFrame.height

        tableView.contentInset = UIEdgeInsets(
            top: 0,
            left: 0,
            bottom: keyboardHeight,
            right: 0
        )
        tableView.scrollIndicatorInsets = tableView.contentInset
    }

    @objc private func keyboardWillHide(notification: NSNotification) {
        tableView.contentInset = .zero
        tableView.scrollIndicatorInsets = .zero
    }

    private func fetchContacts() {
        ContactsService.shared.fetchContacts { [weak self] contacts in
            self?.contacts = contacts
            self?.tableView.reloadData()
        }
    }

    // MARK: - UISearchBarDelegate

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            contacts = ContactsService.shared.getCachedContacts()
        } else {
            contacts = ContactsService.shared.searchContacts(query: searchText)
        }
        tableView.reloadData()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    func setupHideKeyboardOnTap() {
        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(handleBackgroundTap)
        )
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc private func handleBackgroundTap() {
        view.endEditing(true)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int)
        -> Int
    {
        return contacts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
        -> UITableViewCell
    {
        let cell =
            tableView.dequeueReusableCell(
                withIdentifier: "contact_cell",
                for: indexPath
            ) as! ContactTableViewCell
        let contact = contacts[indexPath.row]
        cell.configure(with: contact)
        cell.selectionStyle = .none
        return cell
    }

    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        performSegue(withIdentifier: "addContactPermissionSegue", sender: nil)
    }
}
