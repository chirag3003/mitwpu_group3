import QuickLook
import UIKit

class HealthReportViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var pdfPreviewView: PdfPreviewUIView!
    @IBOutlet weak var closeButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    // MARK: - Properties
    
    /// Remote PDF URL string passed from GenerateSummaryTableViewController
    var remotePDFURL: String?
    
    /// Local file URL for the downloaded PDF
    private var localPDFURL: URL?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        shareButton.tintColor = .systemBlue
        loadReport()
    }
    
    // MARK: - Report Loading
    
    private func loadReport() {
        guard let urlString = remotePDFURL, let url = URL(string: urlString) else {
            showAlert(title: "Error", message: "No report URL provided.")
            return
        }
        
        showLoader(true)
        
        // Download PDF from remote URL
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.showLoader(false)
                
                if let error = error {
                    self.showAlert(title: "Download Failed", message: error.localizedDescription)
                    return
                }
                
                guard let data = data else {
                    self.showAlert(title: "Error", message: "No data received.")
                    return
                }
                
                // Save to temp directory and display
                let tempURL = FileManager.default.temporaryDirectory
                    .appendingPathComponent("HealthReport_\(UUID().uuidString).pdf")
                
                do {
                    try data.write(to: tempURL)
                    self.localPDFURL = tempURL
                    self.pdfPreviewView.setPdf(url: tempURL.path)
                } catch {
                    self.showAlert(title: "Error", message: "Could not save PDF: \(error.localizedDescription)")
                }
            }
        }.resume()
    }
    
    // MARK: - Actions
    
    @IBAction func shareButtonTapped(_ sender: Any) {
        presentShareSheet()
    }
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        dismiss(animated: true)
    }
    
    // MARK: - Share
    
    private func presentShareSheet() {
        guard let pdfURL = localPDFURL else {
            showAlert(title: "Not Ready", message: "Please wait for the report to finish loading.")
            return
        }
        
        // Copy to a user-friendly filename
        let shareURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("Health_Report.pdf")
        do {
            try? FileManager.default.removeItem(at: shareURL)
            try FileManager.default.copyItem(at: pdfURL, to: shareURL)
        } catch {
            // Fall back to original URL
        }
        
        let finalURL = FileManager.default.fileExists(atPath: shareURL.path) ? shareURL : pdfURL
        
        let activityVC = UIActivityViewController(
            activityItems: [finalURL, MailSubjectProvider(subject: "Health Report")],
            applicationActivities: nil
        )
        
        // iPad popover support
        if let popover = activityVC.popoverPresentationController {
            popover.barButtonItem = shareButton
        }
        
        present(activityVC, animated: true)
    }
}

// MARK: - MailSubjectProvider

final class MailSubjectProvider: NSObject, UIActivityItemSource {
    private let subject: String
    
    init(subject: String) {
        self.subject = subject
    }

    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return ""
    }

    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        return ""
    }

    func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivity.ActivityType?) -> String {
        return subject
    }
}
