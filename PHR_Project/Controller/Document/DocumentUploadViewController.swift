import UIKit
import UniformTypeIdentifiers

class DocumentUploadViewController: UITableViewController {
    //  MARK: - IBOutlets

    @IBOutlet weak var reportNameLabel: UITextField!
    @IBOutlet weak var uploadFileButton: UIButton!
    @IBOutlet weak var reportDatePicker: UIDatePicker!

    // MARK: - Properties
    
    private var selectedFileData: Data?
    private var selectedFileName: String?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
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
        uploadReport()
    }

    @IBAction func CloseModalButton(_ sender: Any) {
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
        // Validate report name
        guard let reportName = reportNameLabel.text, !reportName.trimmingCharacters(in: .whitespaces).isEmpty else {
            showAlert(title: "Missing Information", message: "Please enter a report name.")
            return false
        }
        
        // Validate file selection
        guard selectedFileData != nil else {
            showAlert(title: "No File Selected", message: "Please select a PDF file to upload.")
            return false
        }
        
        return true
    }
    
    private func uploadReport() {
        guard validateInputs() else { return }
        
        guard let reportName = reportNameLabel.text?.trimmingCharacters(in: .whitespaces),
              let fileData = selectedFileData,
              let fileName = selectedFileName else {
            return
        }
        
        let reportDate = reportDatePicker.date
        
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
        DocumentService.shared.uploadReport(
            fileData: fileData,
            fileName: fileName,
            title: reportName,
            date: reportDate
        ) { [weak self] success in
            loadingAlert.dismiss(animated: true) {
                if success {
                    self?.dismiss(animated: true)
                } else {
                    self?.showAlert(title: "Upload Failed", message: "Could not upload the report. Please try again.")
                }
            }
        }
    }
}

// MARK: - UIDocumentPickerDelegate

extension DocumentUploadViewController: UIDocumentPickerDelegate {
    
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
