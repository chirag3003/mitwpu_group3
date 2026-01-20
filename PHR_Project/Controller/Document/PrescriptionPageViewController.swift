//
//  PrescriptionPageViewController.swift
//  PHR_Project
//
//  Created by SDC-USER on 10/12/25.
//

import QuickLook
import UIKit

class PrescriptionPageViewController: UIViewController, UITableViewDelegate,
    UITableViewDataSource, QLPreviewControllerDataSource
{

    @IBOutlet weak var tableView: UITableView!

    // MARK: - Properties
    private var prescriptionData: [PrescriptionModel] = []
    private var documentData: [documentsModel] = []
    private var previewURL: URL?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchDocumentData()
        fetchPrescriptionData()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
    }

    // MARK: - Data Fetching
    private func fetchPrescriptionData() {
        prescriptionData = getAllData().document.prescriptionData
    }

    private func fetchDocumentData() {
        documentData = getAllData().document.prescriptions
    }

    // MARK: - TableView Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int)
        -> Int
    {
        return prescriptionData.count
    }

    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        return 65.0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
        -> UITableViewCell
    {
        let cell =
            tableView.dequeueReusableCell(
                withIdentifier: "PrescriptionCell",
                for: indexPath
            ) as! PrescriptionTableViewCell
        let prescription = prescriptionData[indexPath.row]
        cell.configure(with: prescription)
        return cell
    }

    // MARK: - TableView Selection
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
//        tableView.deselectRow(at: indexPath, animated: true)

        let prescription = prescriptionData[indexPath.row]

        print("1. Tapped row: \(prescription.title)")  // DEBUG

        // Check if URL exists
        if let urlString = prescription.pdfUrl, !urlString.isEmpty {
            print("2. URL Found: \(urlString)")  // DEBUG
            showPDFPreview(for: urlString)
        } else {
            print("Error: No URL found for this prescription.")
            let alert = UIAlertController(
                title: "Unavailable",
                message: "No PDF link found for this item.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }

    // MARK: - PDF Preview Logic
    private func showPDFPreview(for urlString: String) {
        guard let url = URL(string: urlString) else {
            print("Error: Invalid URL string")
            return
        }

        // 1. Show Loading Indicator
        let loadingAlert = UIAlertController(
            title: "Downloading...",
            message: "\n\n",
            preferredStyle: .alert
        )
        let spinner = UIActivityIndicatorView(style: .medium)
        spinner.center = CGPoint(x: 135, y: 65.5)  // Center in the alert
        spinner.color = .black
        spinner.startAnimating()
        loadingAlert.view.addSubview(spinner)

        present(loadingAlert, animated: true)

        // 2. Start Download
        URLSession.shared.dataTask(with: url) {
            [weak self] data, response, error in
            guard let self = self else { return }

            // 3. Handle Download Errors
            if let error = error {
                print("Download Error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    loadingAlert.dismiss(animated: true) {
                        self.showErrorAlert(message: "Failed to download PDF.")
                    }
                }
                return
            }

            guard let data = data else {
                print("Error: Data is nil")
                DispatchQueue.main.async {
                    loadingAlert.dismiss(animated: true)
                }
                return
            }

            print("3. Download successful. Data size: \(data.count)")  // DEBUG

            // 4. Save to Temp Directory
            do {
                // Use a unique name so QLPreviewController doesn't show a cached/wrong file
                let uniqueName = "prescription_\(UUID().uuidString).pdf"
                let tempURL = FileManager.default.temporaryDirectory
                    .appendingPathComponent(uniqueName)

                try data.write(to: tempURL)
                self.previewURL = tempURL

                print("4. Saved to: \(tempURL.path)")  // DEBUG

                // 5. Present Preview Controller (Main Thread)
                DispatchQueue.main.async {
                    // IMPORTANT: Dismiss loader FIRST, then present preview
                    loadingAlert.dismiss(animated: true) {
                        let previewController = QLPreviewController()
                        previewController.dataSource = self
                        self.present(previewController, animated: true)
                    }
                }
            } catch {
                print("File Write Error: \(error)")
                DispatchQueue.main.async {
                    loadingAlert.dismiss(animated: true) {
                        self.showErrorAlert(
                            message: "Could not save the PDF file."
                        )
                    }
                }
            }
        }.resume()
    }

    // Helper for errors
    func showErrorAlert(message: String) {
        let alert = UIAlertController(
            title: "Error",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    // MARK: - QLPreviewControllerDataSource
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return previewURL != nil ? 1 : 0
    }

    func previewController(
        _ controller: QLPreviewController,
        previewItemAt index: Int
    ) -> QLPreviewItem {
        return previewURL! as NSURL
    }
}  // End of Class
