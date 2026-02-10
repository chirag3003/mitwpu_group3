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

    @IBOutlet weak var plusButton: UIBarButtonItem!
    @IBOutlet weak var documentTableView: UITableView!
    @IBOutlet weak var dataSegment: UISegmentedControl!

  //  @IBOutlet weak var sortButton: UIBarButtonItem!
    // Properties

    private var doctorsData: [DocDoctor] = []  // Doctors who wrote prescriptions
    private var reportsData: [ReportModel] = []
    private var isNewestFirst = true
    private var previewURL: URL?
    private var isDeleting = false

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
        updateNavigationButtons()
        // Set title based on family member
        if familyMember != nil {
            self.title = "\(familyMember!.name)'s Documents"
        } else {
            self.title = "Documents"
        }

        // Listen for API data updates
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(refreshData),
            name: NSNotification.Name("DocumentsUpdated"),
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(refreshData),
            name: NSNotification.Name("DoctorsUpdated"),
            object: nil
        )
    }

    // MARK: - Setup

    private func setupTableView() {
        documentTableView.delegate = self
        documentTableView.dataSource = self
        documentTableView.separatorStyle = .none
    }

    private func loadData() {
        // Fetch doctors and reports from services
        doctorsData = DocDoctorService.shared.getDoctors()
        reportsData = DocumentService.shared.getAllReports()
    }

    @objc private func refreshData() {
        doctorsData = DocDoctorService.shared.getDoctors()
        reportsData = DocumentService.shared.getAllReports()
        print("Refereshed Data", doctorsData)
        documentTableView.reloadData()
    }
    private func setupPlusButton() {
        // Add target action to plus button
        plusButton.target = self
        plusButton.action = #selector(didTapPlusButton)
    }
    
    // MARK: - Actions

    @IBAction func onDataSwitch(_ sender: Any) {
        documentTableView.reloadData()
        updateNavigationButtons()
    }
    // Toggle sort order
    @IBAction func didTapFilterButton() {
        isNewestFirst.toggle()
            
        sortData()
            
            // 3. Keep the icon as the three-line horizontal symbol
            // (Instead of changing it to arrow.up or arrow.down)
            sortButton.image = UIImage(systemName: "line.3.horizontal.decrease")
            
            // Haptic feedback
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
    }
    private func updateNavigationButtons() {
        if dataSegment.selectedSegmentIndex == 0 {
            // Prescriptions - show only plus button
            navigationItem.rightBarButtonItems = [plusButton]
        } else {
            // Reports - show both plus and sort buttons
            navigationItem.rightBarButtonItems = [plusButton, sortButton]
        }
    }

    @IBAction func didTapPlusButton(_ sender: Any) {
        if dataSegment.selectedSegmentIndex == 0 {
            // Prescriptions segment - Show Add Details modal
            showAddDetailsModal()
        } else {
            // Reports segment - Show Document Upload modal
            showDocumentUploadModal()
        }
    }
   


    // MARK: - Navigation

    private func showAddDetailsModal() {
        // Present Add Details Table View Controller
        let storyboard = UIStoryboard(name: "Documents", bundle: nil)
        if let navController = storyboard.instantiateViewController(
            withIdentifier: "AddDetailsNavViewController"
        ) as? UINavigationController {
            navController.modalPresentationStyle = .pageSheet
            present(navController, animated: true)
        }
    }

    private func showDocumentUploadModal() {
        // Present Document Upload View Controller
        let storyboard = UIStoryboard(name: "Documents", bundle: nil)
        if let uploadVC = storyboard.instantiateViewController(
            withIdentifier: "DocumentUploadNavViewController"
        ) as? UINavigationController {
            uploadVC.modalPresentationStyle = .pageSheet
            present(uploadVC, animated: true)
        }
    }
    // Add this property with your other properties
    private lazy var sortButton: UIBarButtonItem = {
        let button = UIBarButtonItem(
            image: UIImage(systemName: "line.3.horizontal.decrease"),
            style: .plain,
            target: self,
            action: #selector(didTapFilterButton)
        )
        return button
    }()
    // MARK: - Sorting
    // Sort based on selected segment
    private func sortData() {
        if dataSegment.selectedSegmentIndex == 0 {
            //            doctorsData.sort {
            //                compareByDate($0.lastUpdatedAt, $1.lastUpdatedAt)
            //            }
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
            ? doctorsData.count : reportsData.count
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
            // Doctors cell
            let cell =
                tableView.dequeueReusableCell(
                    withIdentifier: CellIdentifiers.doctorCell,
                    for: indexPath
                ) as! DocumentTableViewCell
            let doctor = doctorsData[indexPath.row]
            cell.configure(with: doctor)
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
            if let urlToOpen = reportsData[indexPath.row].pdfUrl {
                showPDFPreview(for: urlToOpen)
            }

        } else {
            // Doctors - Navigate to prescriptions for this doctor
            let doctor = doctorsData[indexPath.row]
            performSegue(withIdentifier: "prescriptionsSegue", sender: doctor)
        }
    }

    // MARK: - Delete Functionality

    func tableView(
        _ tableView: UITableView,
        commit editingStyle: UITableViewCell.EditingStyle,
        forRowAt indexPath: IndexPath
    ) {
        if editingStyle == .delete {
            isDeleting = true

            if dataSegment.selectedSegmentIndex == 0 {
                let doctor = doctorsData[indexPath.row]
                if let doctorId = doctor.apiID {
                    DocDoctorService.shared.deleteDoctor(id: doctorId)
                }
            } else {
                let report = reportsData[indexPath.row]
                if let reportId = report.apiID {
                    DocumentService.shared.deleteDocument(id: reportId)
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.isDeleting = false
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "prescriptionsSegue" {
            if let destinationVC = segue.destination
                as? PrescriptionPageViewController
            {
                // Pass selected doctor info
                if let doctor = sender as? DocDoctor {
                    destinationVC.selectedDoctor = doctor
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
