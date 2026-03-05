//
//  GlucoseTableViewController.swift
//  PHR_Project
//
//  Created by SDC-USER on 22/01/26.
//

import UIKit

class GlucoseTableViewController: UITableViewController, FamilyMemberDataScreen {

    var readings: [GlucoseReading] = [] {
        didSet{
            tableView.reloadData()
        }
    }

    var familyMember: FamilyMember?

    override func viewDidLoad() {
        super.viewDidLoad()
        if let member = familyMember {
            loadSharedReadings(for: member)
        } else {
            readings = GlucoseService.shared.getReadings()
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(updateGlucoseData),
                name: NSNotification.Name(NotificationNames.glucoseUpdated),
                object: nil
            )
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func updateGlucoseData() {
        readings = GlucoseService.shared.getReadings()
    }

    private func loadSharedReadings(for member: FamilyMember) {
        SharedDataService.shared.fetchGlucoseReadings(for: member.userId) { [weak self] result in
            switch result {
            case .success(let readings):
                self?.readings = readings
            case .failure(let error):
                print("Error fetching shared glucose readings: \(error)")
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return readings.count
    }

    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell =
            tableView.dequeueReusableCell(
                withIdentifier: "glucoseCell",
                for: indexPath
            ) as! GlucoseTableViewCell

        let reading = readings[indexPath.row]

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM"
        let dateString = dateFormatter.string(from: reading.combinedDate)

        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "h:mm a"
        let timeString = timeFormatter.string(from: reading.combinedDate)

        var subtitle = timeString
        if let context = reading.mealContext, !context.isEmpty {
            subtitle += " · \(context)"
        }

        cell.configure(
            date: dateString,
            subtitle: subtitle,
            glucose: "\(reading.value)"
        )

        return cell
    }

}
