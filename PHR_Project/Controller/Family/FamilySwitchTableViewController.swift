//
//  FamilySwitchTableViewController.swift
//  PHR_Project
//
//  Created by SDC_USER on 04/03/26.
//

import UIKit

class FamilySwitchTableViewController: UIViewController, UITableViewDelegate,
    UITableViewDataSource
{

    // MARK: - Outlets
    @IBOutlet var tableView: UITableView!
    private var familyNames: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        setupHalfModal()
    }

    private func setupHalfModal() {
        // Check if we are running on iOS 15+ and being presented as a sheet
        if let sheet = self.sheetPresentationController {

            // .medium() starts it at half screen, .large() lets the user drag it to full screen
            sheet.detents = [.medium(), .large()]

            sheet.prefersGrabberVisible = true

            sheet.preferredCornerRadius = 24
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        familyNames = ["Chavans", "The Bhalotias", "Saxena Babies"]

        tableView.reloadData()
    }

    // MARK: - Actions

    @IBAction func closeButtontapped(_ sender: Any) {
        dismiss(animated: true)
    }

    // MARK: - Table View Data Source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int)
        -> Int
    {
        return familyNames.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
        -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "family_cell",
            for: indexPath
        )

        // Configure the cell text
        cell.textLabel?.text = familyNames[indexPath.row]

        return cell
    }

    // MARK: - Table View Delegate
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        tableView.deselectRow(at: indexPath, animated: true)

        // Currently does nothing else, as required for backend handling later
        print("Selected family: \(familyNames[indexPath.row])")
    }

    // MARK: - Context Menu (Long Press)

    func tableView(
        _ tableView: UITableView,
        contextMenuConfigurationForRowAt indexPath: IndexPath,
        point: CGPoint
    ) -> UIContextMenuConfiguration? {

        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil)
        { _ in

            let exitAction = UIAction(
                title: "Exit Family",
                image: UIImage(
                    systemName: "rectangle.portrait.and.arrow.right"
                ),
                attributes: .destructive
            ) { [weak self] _ in

                guard let self = self else { return }

                // Remove the family from your data array
                let exitedFamily = self.familyNames.remove(at: indexPath.row)
                print("Exited family: \(exitedFamily)")

                // Animate the row disappearing from the table view
                DispatchQueue.main.async {
                    self.tableView.deleteRows(at: [indexPath], with: .fade)
                }

                // (Future) Make backend API call here to actually remove the user from the family in the database
            }

            // Return the menu containing action
            return UIMenu(title: "", children: [exitAction])
        }
    }
}
