//
//  PrescriptionUploadTableViewController.swift
//  PHR_Project
//
//  Created by Sushant Pulipati on 27/01/26.
//

import UIKit
import UniformTypeIdentifiers

class PrescriptionUploadTableViewController: UITableViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var uploadFileButton: UIButton!
    @IBOutlet weak var prescriptionDatePicker: UIDatePicker!
    
    // MARK: - Properties
    var selectedDoctor: DocDoctor?
    var doctorName: String?
    
    private var selectedFileData: Data?
    private var selectedFileName: String?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        // Set title to doctor name
        if let doctor = selectedDoctor {
            self.title = doctor.name
            self.navigationItem.title = doctor.name
            doctorName = doctor.name
        } else if let name = doctorName {
            self.title = name
            self.navigationItem.title = name
        }
        
        // Configure upload button initial state
        updateUploadButtonState()
    }
    
    private func updateUploadButtonState() {
        if selectedFileName != nil {
            uploadFileButton.setTitle("✓ \(selectedFileName!)", for: .normal)
            uploadFileButton.setTitleColor(.systemGreen, for: .normal)
        } else {
            uploadFileButton.setTitle("Select PDF File", for: .normal)
            uploadFileButton.setTitleColor(.systemBlue, for: .normal)
        }
    }
    
    // MARK: - Actions
    
    @IBAction func uploadFileButtonTapped(_ sender: Any) {
        presentDocumentPicker()
    }
    
    @IBAction func doneButton(_ sender: Any) {
        uploadPrescription()
    }

    @IBAction func closeButton(_ sender: Any) {
        dismiss(animated: true)
    }
    
    // MARK: - Document Picker
    
    private func presentDocumentPicker() {
        let supportedTypes: [UTType] = [.pdf]
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: supportedTypes)
        picker.delegate = self
        picker.allowsMultipleSelection = false
        present(picker, animated: true)
    }
    
    // MARK: - Validation & Upload
    
    private func validateInputs() -> Bool {
        // Validate doctor is selected
        guard selectedDoctor != nil else {
            showAlert(title: "No Doctor Selected", message: "Please select a doctor for this prescription.")
            return false
        }
        
        // Validate file selection
        guard selectedFileData != nil else {
            showAlert(title: "No File Selected", message: "Please select a PDF file to upload.")
            return false
        }
        
        return true
    }
    
    private func uploadPrescription() {
        guard validateInputs() else { return }
        
        guard let doctorId = selectedDoctor?.apiID else {
            showAlert(title: "Error", message: "Doctor ID not found. Please try again.")
            return
        }
        
        guard let fileData = selectedFileData,
              let fileName = selectedFileName else {
            return
        }
        
        let prescriptionDate = prescriptionDatePicker.date
        
        // Show loading indicator
        let loadingAlert = UIAlertController(title: nil, message: "Uploading...", preferredStyle: .alert)
        let loadingIndicator = UIActivityIndicatorView(style: .medium)
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.startAnimating()
        loadingAlert.view.addSubview(loadingIndicator)
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: loadingAlert.view.centerXAnchor),
            loadingIndicator.bottomAnchor.constraint(equalTo: loadingAlert.view.bottomAnchor, constant: -20)
        ])
        loadingAlert.view.heightAnchor.constraint(equalToConstant: 80).isActive = true
        present(loadingAlert, animated: true)
        
        // Upload via DocumentService
        DocumentService.shared.uploadPrescription(
            fileData: fileData,
            fileName: fileName,
            doctorId: doctorId,
            date: prescriptionDate
        ) { [weak self] success in
            loadingAlert.dismiss(animated: true) {
                if success {
                    self?.dismiss(animated: true)
                } else {
                    self?.showAlert(title: "Upload Failed", message: "Could not upload the prescription. Please try again.")
                }
            }
        }
    }
}

// MARK: - UIDocumentPickerDelegate

extension PrescriptionUploadTableViewController: UIDocumentPickerDelegate {
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let selectedURL = urls.first else { return }
        
        // Start accessing security-scoped resource
        guard selectedURL.startAccessingSecurityScopedResource() else {
            showAlert(title: "Access Denied", message: "Could not access the selected file.")
            return
        }
        
        defer { selectedURL.stopAccessingSecurityScopedResource() }
        
        do {
            let fileData = try Data(contentsOf: selectedURL)
            self.selectedFileData = fileData
            self.selectedFileName = selectedURL.lastPathComponent
            updateUploadButtonState()
        } catch {
            showAlert(title: "Error", message: "Could not read the selected file: \(error.localizedDescription)")
        }
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        // User cancelled - do nothing
    }
}
