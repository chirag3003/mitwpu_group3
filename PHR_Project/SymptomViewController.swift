//
//  SymptomViewController.swift
//  PHR_Project
//
//  Created by SDC_USER on 28/11/25.
//

import UIKit

class SymptomViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    
    @IBOutlet weak var symptomTableView: UITableView!
    
    
    
    var symptomData = Symptoms(
            allSymptoms: [
                Symptom(
                    symptomName: "Migraine",
                    intensity: "High",
                    dateRecorded: CustomDate(day: "Mon,", number: "16th"),
                    notes: "Experiencing sensitivity to light",
                    time: DateComponents(hour: 9, minute: 30)
                ),
                Symptom(
                    symptomName: "Fatigue",
                    intensity: "Medium",
                    dateRecorded: CustomDate(day: "Thu,", number: "27th"),
                    notes: "Feeling sluggish after meals",
                    time: DateComponents(hour: 14, minute: 15)
                ),
                Symptom(
                    symptomName: "Dizziness",
                    intensity: "Low",
                    dateRecorded: CustomDate(day: "Fri,", number: "28th"),
                    notes: "Occurred after standing up too quickly",
                    time: DateComponents(hour: 11, minute: 0)
                )
            ]
        )
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            symptomTableView.dataSource = self
            symptomTableView.delegate = self
            
            // UI Cleanup
            symptomTableView.separatorStyle = .none
//            symptomTableView.backgroundColor = .systemGroupedBackground
//            view.backgroundColor = .systemGroupedBackground
        }
        
        // MARK: - TableView Methods
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return symptomData.allSymptoms.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            // Ensure Identifier in Storyboard is "symptom_cell"
            let cell = tableView.dequeueReusableCell(withIdentifier: "symptom_cell", for: indexPath) as! SymptomTableViewCell
            
            // Get specific symptom
            let currentSymptom = symptomData.allSymptoms[indexPath.row]
            
            // Configure cell
            cell.configure(with: currentSymptom)
            
            return cell
        }
    
    
}
