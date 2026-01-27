import UIKit

    // MARK: - HealthReportViewController
class HealthReportViewController: UIViewController {

    // MARK: - IBOutlets

    @IBOutlet weak var pdfPreviewView: PdfPreviewUIView!
    // Navigation/Toolbar buttons.
    @IBOutlet weak var closeButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    // MARK: - Properties
    var healthReportData: String = "Wade Wilson's Health Report"
    
    // The local file URL where the generated PDF is stored.
    var reportURL: URL?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()

        
      
        
        // Generate PDF and preview it
        if let generatedPdfURL = generateHealthReportPDF() {
            reportURL = generatedPdfURL
            pdfPreviewView.setPdf(url: generatedPdfURL.path)
        }
    }
    // Basic UI configuration
    func setupUI() {
        
        shareButton.tintColor = .systemBlue
    }
    // MARK: - IBActions
    // Triggered when the user taps the Share icon
    @IBAction func shareButtonTapped(_ sender: Any) {
        presentShareSheet()
    }
    // Dismisses the view controller modally
    @IBAction func closeButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    // MARK: - Share Sheet Implementation
    // Configures and presents the UIActivityViewController
    func presentShareSheet() {
        var itemsToShare: [Any] = []
        let pdfURL = reportURL ?? generateHealthReportPDF()
       // Determine what content to share.
        if let pdfURL {
            //Renaming  the file for the recipient
            let destination = FileManager.default.temporaryDirectory
                .appendingPathComponent("Wade_Wilson_Health_Report.pdf")
            do {
                if pdfURL != destination {
                    try? FileManager.default.removeItem(at: destination)
                    try FileManager.default.copyItem(
                        at: pdfURL,
                        to: destination
                    )
                }
                itemsToShare.append(destination)
            } catch {
                //Error Handling
                itemsToShare.append("Wade Wilson’s Health Report - Summary")
            }
        } else {
            
            itemsToShare.append(
                "Wade Wilson’s Health Report - Summary\n\nYour health data goes here..."
            )
        }

       // Email Subject Support
        let subjectProvider = MailSubjectProvider(
            subject: "Wade Wilson’s Health Report"
        )
        itemsToShare.append(subjectProvider)
       // Initialize the Activity View Controller
        let activityVC = UIActivityViewController(
            activityItems: itemsToShare,
            applicationActivities: nil
        )

       // Ensuring all standard share types
        activityVC.excludedActivityTypes = []

        // iPad popover
        if let popover = activityVC.popoverPresentationController {
            if let shareButton = self.shareButton {
                popover.barButtonItem = shareButton
            } else {
                popover.sourceView = self.view
                popover.sourceRect = CGRect(
                    x: self.view.bounds.midX,
                    y: self.view.bounds.midY,
                    width: 0,
                    height: 0
                )
                popover.permittedArrowDirections = []
            }
        }
        //Capturing the result of the share action
        activityVC.completionWithItemsHandler = {
            activityType,
            completed,
            _,
            error in
            if completed {
                self.handleShareCompletion(activityType: activityType)
            }
            if let error { print("Share error: \(error.localizedDescription)") }
        }

        present(activityVC, animated: true)
    }

    // Handles what happens after sharing
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

// MARK: - PDF Generation Extension
extension HealthReportViewController {

    func generateHealthReportPDF() -> URL? {
        // Creating a PDF
        let pdfMetaData = [
            kCGPDFContextCreator: "Health App",
            kCGPDFContextAuthor: "Wade Wilson",
            kCGPDFContextTitle: "Wade Wilson’s Health Report",
        ]

        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]

        let pageRect = CGRect(x: 0, y: 0, width: 595.2, height: 841.8)
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)

        let data = renderer.pdfData { (context) in
            context.beginPage()

            // health report content here
            let titleAttributes = [
                NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 24)
            ]
            let title = "Wade Wilson's Health Report"
            title.draw(
                at: CGPoint(x: 50, y: 50),
                withAttributes: titleAttributes
            )

            let bodyText =
                "Health Report Summary\n\nYour health data goes here"
            let bodyAttributes = [
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)
            ]
            bodyText.draw(
                in: CGRect(x: 50, y: 100, width: 500, height: 700),
                withAttributes: bodyAttributes
            )
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
// MARK: - MailSubjectProvider
final class MailSubjectProvider: NSObject, UIActivityItemSource {
    private let subject: String
    init(subject: String) { self.subject = subject }
    // MARK: UIActivityItemSource Methods

    func activityViewControllerPlaceholderItem(
        _ activityViewController: UIActivityViewController
    ) -> Any {
        return ""
    }

    func activityViewController(
        _ activityViewController: UIActivityViewController,
        itemForActivityType activityType: UIActivity.ActivityType?
    ) -> Any {
        return ""
    }

    func activityViewController(
        _ activityViewController: UIActivityViewController,
        subjectForActivityType activityType: UIActivity.ActivityType?
    ) -> String {
        return subject
    }
}
