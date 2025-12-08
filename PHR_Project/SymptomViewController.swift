//
//  SymptomViewController.swift
//  PHR_Project
//
//  Created by SDC_USER on 28/11/25.
//

import UIKit

class SymptomViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var symptoms: [Symptom] = []
    
    @IBOutlet weak var symptomTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Load data
        symptoms = getAllData().symptoms.allSymptoms

        // Table setup
        symptomTableView.dataSource = self
        symptomTableView.delegate = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return symptoms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Make sure your storyboard/xib cell identifier matches "symptom_cell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "symptom_cell", for: indexPath) as? SymptomTableViewCell else {
            return UITableViewCell()
        }
        let symptom = symptoms[indexPath.row]
        cell.configureSymptomCell(with: symptom)
        return cell
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
