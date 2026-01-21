//
//  PrescriptionPageViewController.swift
//  PHR_Project
//
//  Created by SDC-USER on 10/12/25.
//

import QuickLook
import UIKit

final class PrescriptionPageViewController: UIViewController {

    // MARK: - IBOutlets (Connect in Interface Builder)
    @IBOutlet weak var tableView: UITableView!

    var selectedDoctorName: String?
    // MARK: - Properties
    private var prescriptions: [PrescriptionModel] = []
    private var previewURL: URL?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        loadData()
        print("Selected Doctor Name: \(selectedDoctorName ?? "None")")
        if let name = selectedDoctorName {
            self.title = name
            self.navigationItem.title = name
        }
    }

    // MARK: - Setup
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.showsVerticalScrollIndicator = false
    }

    private func loadData() {
        prescriptions = getAllData().document.prescriptionData
        tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource
extension PrescriptionPageViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int)
        -> Int
    {
        return prescriptions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
        -> UITableViewCell
    {
        guard
            let cell = tableView.dequeueReusableCell(
                withIdentifier: PrescriptionTableViewCell.reuseIdentifier,
                for: indexPath
            ) as? PrescriptionTableViewCell
        else {
            return UITableViewCell()
        }

        let prescription = prescriptions[indexPath.row]
        cell.configure(with: prescription)
        return cell
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "prescriptionsSegue" {

        }
    }
}

// MARK: - UITableViewDelegate
extension PrescriptionPageViewController: UITableViewDelegate {

    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        tableView.deselectRow(at: indexPath, animated: true)

        let prescription = prescriptions[indexPath.row]

        guard let urlString = prescription.pdfUrl, !urlString.isEmpty else {
            showAlert(
                title: "Unavailable",
                message: "No PDF link found for this item."
            )
            return
        }

        downloadAndPreviewPDF(from: urlString)
    }
}

// MARK: - PDF Preview
extension PrescriptionPageViewController: QLPreviewControllerDataSource {

    private func downloadAndPreviewPDF(from urlString: String) {
        guard let url = URL(string: urlString) else {
            showAlert(title: "Error", message: "Invalid URL")
            return
        }

        let loadingVC = createLoadingAlert()
        present(loadingVC, animated: true)

        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            DispatchQueue.main.async {
                loadingVC.dismiss(animated: true) {
                    self?.handleDownloadResult(data: data, error: error)
                }
            }
        }.resume()
    }

    private func handleDownloadResult(data: Data?, error: Error?) {
        if let error = error {
            showAlert(
                title: "Download Failed",
                message: error.localizedDescription
            )
            return
        }

        guard let data = data else {
            showAlert(title: "Error", message: "No data received")
            return
        }

        do {
            let fileName = "prescription_\(UUID().uuidString).pdf"
            let tempURL = FileManager.default.temporaryDirectory
                .appendingPathComponent(fileName)
            try data.write(to: tempURL)
            previewURL = tempURL

            let previewController = QLPreviewController()
            previewController.dataSource = self
            present(previewController, animated: true)
        } catch {
            showAlert(title: "Error", message: "Could not save the PDF file.")
        }
    }

    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return previewURL != nil ? 1 : 0
    }

    func previewController(
        _ controller: QLPreviewController,
        previewItemAt index: Int
    ) -> QLPreviewItem {
        return (previewURL ?? URL(fileURLWithPath: "")) as NSURL
    }
}

// MARK: - Helpers
extension PrescriptionPageViewController {

    private func createLoadingAlert() -> UIAlertController {
        let alert = UIAlertController(
            title: "Downloading...",
            message: "\n\n",
            preferredStyle: .alert
        )
        let spinner = UIActivityIndicatorView(style: .medium)
        spinner.center = CGPoint(x: 135, y: 65.5)
        spinner.startAnimating()
        alert.view.addSubview(spinner)
        return alert
    }

}
