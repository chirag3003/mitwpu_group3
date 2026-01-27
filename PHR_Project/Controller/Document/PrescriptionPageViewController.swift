import QuickLook
import UIKit

final class PrescriptionPageViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!

    var selectedDoctor: DocDoctor?   // Doctor passed from DocumentsViewController
    var selectedDoctorName: String?  // Legacy compatibility
    
     // MARK: - Properties
     private var prescriptions: [PrescriptionModel] = []
     private var previewURL: URL?

     // MARK: - Lifecycle
     override func viewDidLoad() {
         super.viewDidLoad()
         setupTableView()
         loadData()
         
         // Set navigation title to doctor name
         if let doctor = selectedDoctor {
             self.title = doctor.name
             self.navigationItem.title = doctor.name
         } else if let name = selectedDoctorName {
             self.title = name
             self.navigationItem.title = name
         }
         
         // Listen for document updates
         NotificationCenter.default.addObserver(self, selector: #selector(refreshData), name: NSNotification.Name("DocumentsUpdated"), object: nil)
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
         // Load prescriptions filtered by doctor
         if let doctor = selectedDoctor, let doctorId = doctor.apiID {
             // Fetch prescriptions for this specific doctor from API
             prescriptions = DocumentService.shared.getDocumentsByDoctor(doctorId: doctorId)
                 .filter { $0.documentType == .prescription }
                 .map { $0.asLegacyPrescriptionModel }
         } else if let doctorName = selectedDoctorName {
             // Legacy: filter by name
             prescriptions = PrescriptionService.shared.getPrescriptionsByDoctor(doctorName)
         } else {
             prescriptions = PrescriptionService.shared.getAllPrescriptionData()
         }
         tableView.reloadData()
     }
     
     @objc private func refreshData() {
         loadData()
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
 }

 // MARK: - UITableViewDelegate
 extension PrescriptionPageViewController: UITableViewDelegate {

     func tableView(
         _ tableView: UITableView,
         didSelectRowAt indexPath: IndexPath
     ) {
         tableView.deselectRow(at: indexPath, animated: true)

         let prescription = prescriptions[indexPath.row]
         
         // Validate PDF URL exists

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
         // Show loading indicator
         let loadingVC = createLoadingAlert()
         present(loadingVC, animated: true)
         // Download PDF data

         URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
             DispatchQueue.main.async {
                 loadingVC.dismiss(animated: true) {
                     self?.handleDownloadResult(data: data, error: error)
                 }
             }
         }.resume()
     }

     private func handleDownloadResult(data: Data?, error: Error?) {
         // Handle download errors
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
             // Saving  PDF to temp directory with another unique name
             let fileName = "prescription_\(UUID().uuidString).pdf"
             let tempURL = FileManager.default.temporaryDirectory
                 .appendingPathComponent(fileName)
             try data.write(to: tempURL)
             previewURL = tempURL
             // Present PDF preview
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
         // Create loading alert with spinner
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
