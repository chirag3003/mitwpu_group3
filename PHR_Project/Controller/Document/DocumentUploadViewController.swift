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
