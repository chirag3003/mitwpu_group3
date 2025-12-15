//
//  PrescriptionPageViewController.swift
//  PHR_Project
//
//  Created by SDC-USER on 10/12/25.
//

import UIKit
class PrescriptionPageViewController:UIViewController,UITableViewDelegate,UITableViewDataSource{
    
    private var prescriptionData: [PrescriptionModel] = []
    
    @IBOutlet weak var tableView: UITableView!
    private var documentData: [documentsModel] = []
    private func fetchPrescriptionData() {
        prescriptionData = getAllData().document.prescriptionData
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchDocumentData()
        fetchPrescriptionData()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
    }
    
    private func fetchDocumentData() {
        documentData = getAllData().document.prescriptions
    }
    
    
    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        
        return 65.0  
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return prescriptionData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PrescriptionCell", for: indexPath) as! PrescriptionTableViewCell
        let prescription = prescriptionData[indexPath.row]
        cell.configure(with: prescription)
        return cell
    }
    
}
