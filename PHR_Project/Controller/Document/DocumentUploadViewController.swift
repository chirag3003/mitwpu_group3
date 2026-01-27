//
//  GenerateHealthReport.swift
//  PHR_Project
//
//  Created by SDC-USER on 27/11/25.
//

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
//    
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
//        // Handle Capture Document Image
//    func didCaptureDocument(_ image: UIImage) {
//        print("Document scanned by camera")
//    }
//    
//    
//}
