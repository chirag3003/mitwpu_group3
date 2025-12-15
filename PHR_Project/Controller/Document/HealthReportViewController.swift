import UIKit

class HealthReportViewController: UIViewController {
    
    // MARK: - IBOutlets
 
    
    @IBOutlet weak var closeButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    // Store your health report data
    var healthReportData: String = "Wade Wilson's Health Report"
    var reportURL: URL? // If you have a PDF or document
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI() {
        // Configure share button appearance if needed
        shareButton.tintColor = .systemBlue
    }
    
    @IBAction func shareButtonTapped(_ sender: Any) {
        presentShareSheet()
    }
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    // MARK: - Share Sheet Implementation
    func presentShareSheet() {
        var itemsToShare: [Any] = []

        // Prefer a PDF so you get preview + Markup
        let pdfURL = reportURL ?? generateHealthReportPDF()

        if let pdfURL {
            // Copy to a predictable, readable filename for better presentation
            let destination = FileManager.default.temporaryDirectory
                .appendingPathComponent("Wade_Wilson_Health_Report.pdf")
            do {
                if pdfURL != destination {
                    try? FileManager.default.removeItem(at: destination)
                    try FileManager.default.copyItem(at: pdfURL, to: destination)
                }
                itemsToShare.append(destination)
            } catch {
                // Fallback to text if copy fails
                itemsToShare.append("Wade Wilson’s Health Report - Summary")
            }
        } else {
            // Final fallback: plain text
            itemsToShare.append("Wade Wilson’s Health Report - Summary\n\nYour health data goes here...")
        }

        // Provide a subject for Mail via UIActivityItemSource
        let subjectProvider = MailSubjectProvider(subject: "Wade Wilson’s Health Report")
        itemsToShare.append(subjectProvider)

        let activityVC = UIActivityViewController(activityItems: itemsToShare, applicationActivities: nil)

        // Keep the full sheet (don’t exclude)
        activityVC.excludedActivityTypes = []

        // iPad popover
        if let popover = activityVC.popoverPresentationController {
            if let shareButton = self.shareButton {
                popover.barButtonItem = shareButton
            } else {
                popover.sourceView = self.view
                popover.sourceRect = CGRect(x: self.view.bounds.midX,
                                            y: self.view.bounds.midY,
                                            width: 0,
                                            height: 0)
                popover.permittedArrowDirections = []
            }
        }

        activityVC.completionWithItemsHandler = { activityType, completed, _, error in
            if completed {
                self.handleShareCompletion(activityType: activityType)
            }
            if let error { print("Share error: \(error.localizedDescription)") }
        }

        present(activityVC, animated: true)
    }
    
    // Handle what happens after sharing
    func handleShareCompletion(activityType: UIActivity.ActivityType?) {
        guard let activityType = activityType else { return }
        
        switch activityType {
        case .message:
            print("Shared via Messages")
        case .mail:
            print("Shared via Mail")
        case .airDrop:
            print("Shared via AirDrop")
        case .copyToPasteboard:
            print("Copied to clipboard")
        default:
            print("Shared via: \(activityType.rawValue)")
        }
    }
}

// MARK: - Extension for creating PDF from Health Report (Example)
extension HealthReportViewController {
    
    func generateHealthReportPDF() -> URL? {
        // Create a PDF from your health data
        let pdfMetaData = [
            kCGPDFContextCreator: "Health App",
            kCGPDFContextAuthor: "Wade Wilson",
            kCGPDFContextTitle: "Wade Wilson’s Health Report"
        ]
        
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        let pageRect = CGRect(x: 0, y: 0, width: 595.2, height: 841.8) // A4 size
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        let data = renderer.pdfData { (context) in
            context.beginPage()
            
            // Draw your health report content here
            let titleAttributes = [
                NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 24)
            ]
            let title = "Wade Wilson's Health Report"
            title.draw(at: CGPoint(x: 50, y: 50), withAttributes: titleAttributes)
            
            let bodyText = "Health Report Summary\n\nYour health data goes here tralalelo tralala..."
            let bodyAttributes = [
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)
            ]
            bodyText.draw(in: CGRect(x: 50, y: 100, width: 500, height: 700),
                         withAttributes: bodyAttributes)
        }
        
        // Save to temporary directory
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("HealthReport.pdf")
        
        do {
            try data.write(to: tempURL)
            return tempURL
        } catch {
            print("Could not create PDF: \(error.localizedDescription)")
            return nil
        }
    }
}

final class MailSubjectProvider: NSObject, UIActivityItemSource {
    private let subject: String
    init(subject: String) { self.subject = subject }

    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return ""
    }

    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any {
        return ""
    }

    func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivity.ActivityType?) -> String {
        return subject
    }
}
