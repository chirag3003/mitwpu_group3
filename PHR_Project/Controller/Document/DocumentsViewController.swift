//
//  DocumentsViewController.swift
//  PHR_Project
//
//  Created by SDC-USER on 25/11/25.
//

import QuickLook
import UIKit

class DocumentsViewController: UIViewController {
    
    // MARK: - IBOutlets
    
   

    @IBOutlet weak var documentTableView: UITableView!
    @IBOutlet weak var dataSegment: UISegmentedControl!
    
    // MARK: - Properties
    
    private var documentData: [documentsModel] = []
    private var reportsData: [ReportModel] = []
    private var isNewestFirst = true
    private var previewURL: URL?
    
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
        
        
    }
    
    // MARK: - Setup
    
    private func setupTableView() {
        documentTableView.delegate = self
        documentTableView.dataSource = self
        documentTableView.separatorStyle = .none
    }
    
    private func loadData() {
        let allData = getAllData()
        documentData = allData.document.prescriptions
        reportsData = allData.document.reports
    }
    
    // MARK: - Actions
    
    @IBAction func onDataSwitch(_ sender: Any) {
        documentTableView.reloadData()
    }
    
    @IBAction func didTapFilterButton() {
        isNewestFirst.toggle()
        sortData()
        
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    // MARK: - Sorting
    
    private func sortData() {
        if dataSegment.selectedSegmentIndex == 0 {
            documentData.sort { compareByDate($0.lastUpdatedAt, $1.lastUpdatedAt) }
        } else {
            reportsData.sort { compareByDate($0.lastUpdatedAt, $1.lastUpdatedAt) }
        }
        documentTableView.reloadData()
    }
    
    private func compareByDate(_ date1String: String, _ date2String: String) -> Bool {
        let date1 = dateFormatter.date(from: date1String) ?? Date.distantPast
        let date2 = dateFormatter.date(from: date2String) ?? Date.distantPast
        return isNewestFirst ? date1 > date2 : date1 < date2
    }
    
    // MARK: - PDF Preview
    
    private func showPDFPreview(for urlString: String) {
        guard let url = URL(string: urlString) else { return }
        
        // Show loading alert
        let loadingAlert = UIAlertController(title: nil, message: "Loading PDF...", preferredStyle: .alert)
        let loadingIndicator = UIActivityIndicatorView(style: .medium)
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.startAnimating()
        loadingAlert.view.addSubview(loadingIndicator)
        
        NSLayoutConstraint.activate([
            loadingIndicator.centerYAnchor.constraint(equalTo: loadingAlert.view.centerYAnchor),
            loadingIndicator.leadingAnchor.constraint(equalTo: loadingAlert.view.leadingAnchor, constant: 20),
            loadingAlert.view.heightAnchor.constraint(equalToConstant: 80)
        ])
        
        present(loadingAlert, animated: true)
        
        // Download PDF to temporary location for QuickLook
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("report.pdf")
        
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            DispatchQueue.main.async {
                loadingAlert.dismiss(animated: true) {
                    guard let data = data, error == nil else {
                        self?.showErrorAlert(message: "Failed to load PDF")
                        return
                    }
                    
                    do {
                        try data.write(to: tempURL)
                        self?.previewURL = tempURL
                        
                        let previewController = QLPreviewController()
                        previewController.dataSource = self
                        self?.present(previewController, animated: true)
                    } catch {
                        self?.showErrorAlert(message: "Failed to open PDF")
                    }
                }
            }
        }.resume()
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDelegate & DataSource

extension DocumentsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSegment.selectedSegmentIndex == 0 ? documentData.count : reportsData.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return DefaultValues.defaultTableRowHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if dataSegment.selectedSegmentIndex == 0 {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: CellIdentifiers.doctorCell,
                for: indexPath
            ) as! DocumentTableViewCell
            cell.configure(with: documentData[indexPath.row])
            cell.selectionStyle = .none
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: CellIdentifiers.reportCell,
                for: indexPath
            ) as! ReportsTableViewCell
            cell.configure(with: reportsData[indexPath.row])
            cell.selectionStyle = .none
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Demo URL - replace with actual report URL from model
        let demoURL = "https://cdn1.lalpathlabs.com/live/reports/Z615.pdf"
        showPDFPreview(for: demoURL)
    }
}

// MARK: - QLPreviewControllerDataSource

extension DocumentsViewController: QLPreviewControllerDataSource {
    
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return previewURL != nil ? 1 : 0
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return previewURL! as QLPreviewItem
    }
}

