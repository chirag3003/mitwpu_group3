//
//  GenerateHealthViewController.swift
//  PHR_Project
//
//  Created by SDC-USER on 28/11/25.
//

import UIKit
class GenerateHealthViewController: UIViewController {
    
    @IBOutlet weak var dateInputView: UIStackView!
    
    @IBOutlet weak var TypeOfVisitView: UIView!
    
    @IBOutlet weak var DataFields: UIView!
    @IBOutlet weak var fromDatePicker: UIDatePicker!
    
    @IBOutlet weak var TextField: UITextField!
    @IBOutlet weak var AdditionalNotes: UIView!
    override func viewDidLoad() {
    
        super.viewDidLoad()
        dateInputView.addRoundedCorner()
        TypeOfVisitView.addRoundedCorner()
        DataFields.addRoundedCorner()
        AdditionalNotes.addRoundedCorner()
        TextField.addRoundedCorner(radius:10
        )
        
    }
    @IBAction func toggleSelection(_ sender: UIButton) {
       
            sender.isSelected.toggle()
            
            // Optional: Print which one was clicked based on the label next to it?
            // In a real app, you might want to tag your buttons 0-5 in storyboard to identify them.
            if sender.isSelected {
                print("Item Selected")
            } else {
                print("Item Deselected")
            }
    }
}


