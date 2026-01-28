import UIKit

class DocumentUploadViewController: UITableViewController   {
    //  MARK: -IBOutlets
    
   // @IBOutlet weak var scanFileView: UIView!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        //Adding rounded corners
       // scanFileView.addRoundedSides()
        //uploadDocumentView.addRoundedCorner()
    }
    //MARK: - ACTIONS
    @IBAction func doneButton(_ sender: Any) {
        dismiss(animated: true)
    }
    
@IBAction func CloseModalButton(_ sender: Any) {
        dismiss(animated: true)
        
    }
}

// MARK: - CustomDocumentScannerDelegate
//extension DocumentUploadViewController: CustomDocumentScannerDelegate {
//    
//    @IBAction func addDocumentCamera(_ sender: Any) {
//        // Initialize custom camera scanner
//        let customCameraVC = CustomDocumentScannerViewController()
//        customCameraVC.delegate = self
//        
//        // Present camera full screen
//        customCameraVC.modalPresentationStyle = .fullScreen
//        present(customCameraVC, animated: true)
//    }
//    
//    // Handle Capture Document Image
//    func didCaptureDocument(_ image: UIImage) {
//        print("Document scanned by camera")
//        
//        // Convert image to PDF data
//        if let imageData = image.jpegData(compressionQuality: 0.8) {
//            self.scannedImageData = imageData
//            
//            // Show title input dialog
//            showReportTitleInput()
//        }
//    }
//    
//    private func showReportTitleInput() {
//        let alert = UIAlertController(
//            title: "Report Title",
//            message: "Enter a title for this report",
//            preferredStyle: .alert
//        )
//        
//        alert.addTextField { textField in
//            textField.placeholder = "e.g., Blood Test Results"
//        }
//        
//        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
//        alert.addAction(UIAlertAction(title: "Upload", style: .default) { [weak self] _ in
//            guard let self = self,
//                  let title = alert.textFields?.first?.text,
//                  !title.isEmpty,
//                  let imageData = self.scannedImageData else {
//                return
//            }
//            
//            self.uploadReport(title: title, data: imageData)
//        })
//        
//        present(alert, animated: true)
//    }
//    
//    private func uploadReport(title: String, data: Data) {
//        let fileName = "\(title.replacingOccurrences(of: " ", with: "_")).jpg"
//        
//        DocumentService.shared.uploadReport(
//            fileData: data,
//            fileName: fileName,
//            title: title,
//            date: Date()
//        ) { [weak self] success in
//            if success {
//                self?.dismiss(animated: true)
//            } else {
//                self?.showAlert(title: "Upload Failed", message: "Could not upload the report. Please try again.")
//            }
//        }
//    }
//}
//
