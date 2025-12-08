//
//  SymptomViewController.swift
//  PHR_Project
//
//  Created by SDC_USER on 28/11/25.
//

import UIKit

class SymptomViewController: UIViewController, UITableViewDelegate,
    UITableViewDataSource
{

    @IBOutlet weak var symptomTableView: UITableView!

    var symptomsData: [Symptom] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        // data setup
        symptomsData = SymptomService.shared.getSymptoms()

        symptomTableView.dataSource = self
        symptomTableView.delegate = self

        // UI Cleanup
        symptomTableView.separatorStyle = .none
        //            symptomTableView.backgroundColor = .systemGroupedBackground
        //            view.backgroundColor = .systemGroupedBackground
        //setting up event listeners
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateSymptoms),
            name: NSNotification.Name("SymptomsUpdated"),
            object: nil
        )
    }

    // MARK: - TableView Methods

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int)
        -> Int
    {
        return symptomsData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
        -> UITableViewCell
    {
        // Ensure Identifier in Storyboard is "symptom_cell"
        let cell =
            tableView.dequeueReusableCell(
                withIdentifier: "symptom_cell",
                for: indexPath
            ) as! SymptomTableViewCell

        // Get specific symptom
        let currentSymptom = symptomsData[indexPath.row]

        // Configure cell
        cell.configure(with: currentSymptom)

        return cell
    }

    func reloadData() {
        symptomsData = SymptomService.shared.getSymptoms()
        symptomTableView.reloadData()
    }

    @objc func updateSymptoms() {
        let profile = ProfileService.shared.getProfile()
        reloadData()
        // Update your labels here...
    }

}
