//
//  GenerateHealthReport.swift
//  PHR_Project
//
//  Created by SDC-USER on 27/11/25.
//

import UIKit

class DocumentUploadViewController: UIViewController {
    
    @IBOutlet weak var scanFileView: UIView!
    @IBOutlet weak var uploadDocumentView: UIView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        //Adding rounded corners
        scanFileView.addRoundedSides()
        uploadDocumentView.addRoundedSides()
    }
    
    
@IBAction func CloseModalButton(_ sender: Any) {
        dismiss(animated: true)
        
    }
}


extension DocumentUploadViewController: CustomDocumentScannerDelegate {
    
    
    
    @IBAction func addDocumentCamera(_ sender: Any) {
        // Create the custom camera VC
        let customCameraVC = CustomDocumentScannerViewController()
        
        // Set the delegate to 'self' so we get the results back
        customCameraVC.delegate = self
        
        // Present it full screen
        customCameraVC.modalPresentationStyle = .fullScreen
        present(customCameraVC, animated: true)
    }
    
    func didCaptureDocument(_ image: UIImage) {
        print("Document scanned by camera")
    }
    
    
}
