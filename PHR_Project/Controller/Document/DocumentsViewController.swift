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
    
    private lazy var filterButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "line.3.horizontal.decrease")
        config.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 15, weight: .semibold)
        config.baseForegroundColor = .label
        config.background.visualEffect = UIBlurEffect(style: .systemThinMaterial)
        config.background.backgroundColor = .systemBackground.withAlphaComponent(0.3)
        config.cornerStyle = .capsule
        
        let button = UIButton(configuration: config, primaryAction: nil)
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.1
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        button.addTarget(self, action: #selector(didTapFilterButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupFilterButton()
        loadData()
    }
    
    // MARK: - Setup
    
    private func setupTableView() {
        documentTableView.delegate = self
        documentTableView.dataSource = self
        documentTableView.separatorStyle = .none
    }
    
    private func setupFilterButton() {
        view.addSubview(filterButton)
        filterButton.translatesAutoresizingMaskIntoConstraints = false
        documentTableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            filterButton.topAnchor.constraint(equalTo: dataSegment.bottomAnchor, constant: 12),
            filterButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            filterButton.widthAnchor.constraint(equalToConstant: 36),
            filterButton.heightAnchor.constraint(equalToConstant: 36),
            documentTableView.topAnchor.constraint(equalTo: filterButton.bottomAnchor, constant: 10),
            documentTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            documentTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            documentTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
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
    
    @objc private func didTapFilterButton() {
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

