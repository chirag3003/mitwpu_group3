//
//  DocumentsViewController.swift
//  PHR_Project
//
//  Created by SDC-USER on 25/11/25.
//

import QuickLook
import UIKit

class DocumentsViewController: UIViewController, FamilyMemberDataScreen {

    // MARK: - IBOutlets

    @IBOutlet weak var documentTableView: UITableView!
    @IBOutlet weak var dataSegment: UISegmentedControl!


    // Properties

    private var documentData: [documentsModel] = []
    private var reportsData: [ReportModel] = []
    private var isNewestFirst = true
    private var previewURL: URL?
    
    // Family Members
    var familyMember: FamilyMember?
    // Date Formattter for sorting
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM yyyy"
        return formatter
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        loadData()
    // Set title based on family member
        if(familyMember != nil){
            self.title = "\(familyMember!.name)'s Documents"
        } else {
            self.title = "Documents"
        }

    }

    // MARK: - Setup

    private func setupTableView() {
        documentTableView.delegate = self
        documentTableView.dataSource = self
        documentTableView.separatorStyle = .none
    }

    private func loadData() {
        //Fetch data from services
        documentData = DocumentService.shared.getAllPrescriptions()
        reportsData = DocumentService.shared.getAllReports()
    }

    // MARK: - Actions

    @IBAction func onDataSwitch(_ sender: Any) {
        documentTableView.reloadData()
    }
     // Toggle sort order
    @IBAction func didTapFilterButton() {
        isNewestFirst.toggle()
        sortData()
    // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }

    // MARK: - Sorting
    // Sort based on selected segment
    private func sortData() {
        if dataSegment.selectedSegmentIndex == 0 {
            documentData.sort {
                compareByDate($0.lastUpdatedAt, $1.lastUpdatedAt)
            }
        } else {
            reportsData.sort {
                compareByDate($0.lastUpdatedAt, $1.lastUpdatedAt)
            }
        }
        documentTableView.reloadData()
    }

    private func compareByDate(_ date1String: String, _ date2String: String)
        -> Bool
    {
        let date1 = dateFormatter.date(from: date1String) ?? Date.distantPast
        let date2 = dateFormatter.date(from: date2String) ?? Date.distantPast
        return isNewestFirst ? date1 > date2 : date1 < date2
    }

    // MARK: - PDF Preview

    private func showPDFPreview(for urlString: String) {
        guard let url = URL(string: urlString) else {
            showErrorAlert(message: "Invalid URL format.")
            return
        }

        //  Show Loading Indicator
        let loadingAlert = UIAlertController(
            title: nil,
            message: "Loading PDF...",
            preferredStyle: .alert
        )
        let loadingIndicator = UIActivityIndicatorView(style: .medium)
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.startAnimating()
        loadingAlert.view.addSubview(loadingIndicator)
        // Constraints for loading indicator
        NSLayoutConstraint.activate([
            loadingIndicator.centerYAnchor.constraint(
                equalTo: loadingAlert.view.centerYAnchor
            ),
            loadingIndicator.leadingAnchor.constraint(
                equalTo: loadingAlert.view.leadingAnchor,
                constant: 20
            ),
            loadingAlert.view.heightAnchor.constraint(equalToConstant: 80),
        ])

        present(loadingAlert, animated: true)

        // Download PDF
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            DispatchQueue.main.async {
                // Dismiss loader first
                loadingAlert.dismiss(animated: true) {
                    guard let self = self else { return }

                    if let error = error {
                        self.showErrorAlert(
                            message:
                                "Download failed: \(error.localizedDescription)"
                        )
                        return
                    }

                    guard let data = data else {
                        self.showErrorAlert(message: "PDF file data is empty.")
                        return
                    }

                    do {
                        // Save PDF to temp directory with unique name
                        let uniqueFileName = "report_\(UUID().uuidString).pdf"
                        let tempURL = FileManager.default.temporaryDirectory
                            .appendingPathComponent(uniqueFileName)

                        try data.write(to: tempURL)
                        self.previewURL = tempURL

                        // Show PDF preview
                        let previewController = QLPreviewController()
                        previewController.dataSource = self
                        self.present(previewController, animated: true)

                    } catch {
                        self.showErrorAlert(message: "Failed to save PDF file.")
                        print("File Write Error: \(error)")
                    }
                }
            }
        }.resume()
    }

    private func showErrorAlert(message: String) {
        let alert = UIAlertController(
            title: "Error",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDelegate & DataSource

extension DocumentsViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int)
        -> Int
    {
        // Return count based on selected segment
        return dataSegment.selectedSegmentIndex == 0
            ? documentData.count : reportsData.count
    }

    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        return DefaultValues.defaultTableRowHeight
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
        -> UITableViewCell
    {
        // Configure cell based on segment
        if dataSegment.selectedSegmentIndex == 0 {
            // Documents cell
            let cell =
                tableView.dequeueReusableCell(
                    withIdentifier: CellIdentifiers.doctorCell,
                    for: indexPath
                ) as! DocumentTableViewCell
            cell.configure(with: documentData[indexPath.row])
            cell.selectionStyle = .none
            return cell
        } else {
            // Reports cell
            let cell =
                tableView.dequeueReusableCell(
                    withIdentifier: CellIdentifiers.reportCell,
                    for: indexPath
                ) as! ReportsTableViewCell
            cell.configure(with: reportsData[indexPath.row])
            cell.selectionStyle = .none
            return cell
        }
    }

    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        if dataSegment.selectedSegmentIndex == 1 {
            
            // Reports - Open PDF
            let dummyPDFLink =
                "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf"

            let report = reportsData[indexPath.row]

            let urlToOpen = dummyPDFLink  // Default to dummy

            showPDFPreview(for: urlToOpen)

        } else {
            // Documents - Navigate to prescriptions
            
            let document = documentData[indexPath.row]
            performSegue(withIdentifier: "prescriptionsSegue", sender: document)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        
        if segue.identifier == "prescriptionsSegue" {

            
            if let destinationVC = segue.destination
                as? PrescriptionPageViewController
            {

                // Pass selected doctor name
                if let document = sender as? documentsModel {

                    destinationVC.selectedDoctorName = document.title
                }
            }
        }
    }

}

// MARK: - QLPreviewControllerDataSource

extension DocumentsViewController: QLPreviewControllerDataSource {

    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return previewURL != nil ? 1 : 0
    }

    func previewController(
        _ controller: QLPreviewController,
        previewItemAt index: Int
    ) -> QLPreviewItem {
        return previewURL! as QLPreviewItem
    }
}
