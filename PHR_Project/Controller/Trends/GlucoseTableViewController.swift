//
//  GlucoseTableViewController.swift
//  PHR_Project
//
//  Created by SDC-USER on 22/01/26.
//

import UIKit

class GlucoseTableViewController: UITableViewController {

    var readings: [GlucoseReading] = [] {
        didSet{
            tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        readings = GlucoseService.shared.getReadings()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateGlucoseData),
            name: NSNotification.Name(NotificationNames.glucoseUpdated),
            object: nil
        )
    }
    
    @objc func updateGlucoseData() {
        readings = GlucoseService.shared.getReadings()
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

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
    
    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
