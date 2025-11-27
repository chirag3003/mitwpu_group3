//
//  DocumentsViewController.swift
//  PHR_Project
//
//  Created by SDC-USER on 25/11/25.
//
import UIKit

class DocumentsViewController: UIViewController, UITableViewDelegate,
    UITableViewDataSource
{

    @IBOutlet weak var documentTableView: UITableView!

    @IBOutlet weak var dataSegment: UISegmentedControl!
    private var documentData: [documentsModel] = []
    private var reportsData: [ReportModel] = []

    private func fetchDocumentData() {
        documentData = [
            documentsModel(
                id: UUID(),
                title: "Dr. Abhishek Khare",
                lastUpdatedAt: "15 Nov 2025"
            ),
            documentsModel(
                id: UUID(),
                title: "Dr. B",
                lastUpdatedAt: "16 Nov 2025"
            ),
            documentsModel(
                id: UUID(),
                title: "Dr. C",
                lastUpdatedAt: "18 Nov 2025"
            ),
            documentsModel(
                id: UUID(),
                title: "Dr. D",
                lastUpdatedAt: "19 Nov 2025"
            ),
            documentsModel(
                id: UUID(),
                title: "Dr. E",
                lastUpdatedAt: "20 Nov 2025"
            ),
        ]
    }
    private func fetchReportsData() {
        reportsData = [
            ReportModel(
                id: UUID(),
                title: "H1ABC",
                lastUpdatedAt: "15 Nov 2025",
                fileSize: "3MB"
            ),
            ReportModel(
                id: UUID(),
                title: "Sugar",
                lastUpdatedAt: "16 Nov 2025",
                fileSize: "5MB"
            ),
        ]
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        fetchDocumentData()
        fetchReportsData()

        documentTableView.delegate = self
        documentTableView.dataSource = self
        documentTableView.separatorStyle = .none

    }
    
    
    
    
    @IBAction func onDataSwitch(_ sender: Any) {
        documentTableView.reloadData()
    }
    
    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        // Reduce this value significantly.
        // Try values between 60.0 and 75.0, depending on the desired space.
        return 65.0  // Example of a reduced height
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int)
        -> Int
    {
        if(dataSegment.selectedSegmentIndex == 0){
            return documentData.count
        }
        return reportsData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
        -> UITableViewCell
    {
        if(dataSegment.selectedSegmentIndex == 0){
            let cell =
            tableView.dequeueReusableCell(
                withIdentifier: "DoctorCell",
                for: indexPath
            ) as! DocumentTableViewCell
            let doctor = documentData[indexPath.row]
            cell.configure(with: doctor)
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReportCell", for: indexPath) as! ReportsTableViewCell
        let report = reportsData[indexPath.row]
        cell.configure(with: report)
        return cell
    }

}

