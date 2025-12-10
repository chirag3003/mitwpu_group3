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
    
    @IBOutlet  var allCheckboxButtons:UIButton!
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
//        if let buttons = allCheckboxButtons {
//                    for btn in buttons {
//                        configureCheckbox(btn)
//                    }
//                }
    }
    @IBAction func toggleSelection(_ sender: UIButton) {
       
            sender.isSelected.toggle()
            
            // Optional: Print which one was clicked based on the label next to it?
            // In a real app, you might want to tag your buttons 0-5 in storyboard to identify them.
        
    }
    
    func configureCheckbox(_ button: UIButton) {
        // 1. Set the Empty Circle for the normal state
        let emptyCircle = UIImage(systemName: "circle")
        button.setImage(emptyCircle, for: .normal)
        
        // 2. Set the Filled Circle for the selected state
        let filledCircle = UIImage(systemName: "circle.fill")
        button.setImage(filledCircle, for: .selected)
        
        // 3. Set your blue color
        button.tintColor = UIColor.systemBlue // Replace with your custom blue
    }
}


