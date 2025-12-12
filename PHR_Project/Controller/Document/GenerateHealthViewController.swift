//
//  GenerateHealthViewController.swift
//  PHR_Project
//
//  Created by SDC-USER on 28/11/25.
//

import UIKit
class GenerateHealthViewController: UIViewController {
    
    
    @IBOutlet weak var dateInputView: UIView!
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
        TextField.addRoundedCorner(radius:10)
       
    }
    

    @IBAction func toggleSelection(_ sender: UISwitch) {
        sender.isSelected.toggle()
        if sender.isSelected {
                print("Button turned ON")
            } else {
                print("Button turned OFF")
            }
    }
    
    

    

}


