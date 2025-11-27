//
//  DocumentsViewController.swift
//  PHR_Project
//
//  Created by SDC-USER on 25/11/25.
//
import UIKit

class DocumentsViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var documentTableView: UITableView!
    
    
    
    
    private var documentData: [documentsModel] = []
    private func fetchDocumentData(){
        documentData = [
            documentsModel(id: UUID(), title: "Dr.Abhishek Khare",lastUpdatedAt: "15 Nov 2025"),
            documentsModel(id: UUID(), title: "Dr.B",lastUpdatedAt: "16 Nov 2025"),
            documentsModel(id: UUID(), title: "Dr.C",lastUpdatedAt: "18 Nov 2025"),
            documentsModel(id: UUID(), title: "Dr.D",lastUpdatedAt: "19 Nov 2025"),
            documentsModel(id: UUID(), title: "Dr.E",lastUpdatedAt: "20 Nov 2025")
        ]
    }
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchDocumentData()
        
        documentTableView.delegate = self
        documentTableView.dataSource = self
        documentTableView.separatorStyle = .none
        
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // Reduce this value significantly.
        // Try values between 60.0 and 75.0, depending on the desired space.
        return 65.0 // Example of a reduced height
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return documentData.count
    }

    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let cell = tableView.dequeueReusableCell(withIdentifier: "DoctorCell", for: indexPath) as!DocumentTableViewCell
            let doctor = documentData[indexPath.row]
        cell.configure(with: doctor)
            return cell
        }
        
    }
    
    

