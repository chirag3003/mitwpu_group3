//
//  FamilyPermissionViewController.swift
//  PHR_Project
//
//  Created by SDC_USER on 25/11/25.
//

import UIKit

class FamilyPermissionViewController: UIViewController {
   
    
    @IBOutlet weak var documentSwitch: UISwitch!
    @IBOutlet weak var readWriteSwitch: UISwitch!
    @IBOutlet weak var trendSwitch: UISwitch!
    @IBOutlet weak var symptomLogSwitch: UISwitch!
    @IBOutlet weak var mealLogSwitch: UISwitch!
    @IBOutlet weak var readOnlySwitch: UISwitch!
    override func viewDidLoad() {
        
        
        
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func onTurnOnAllButton(_ sender: UIButton) {
        
        documentSwitch.setOn(true, animated: true)
        mealLogSwitch.setOn(true, animated: true)
        symptomLogSwitch.setOn(true, animated: true)
        trendSwitch.setOn(true, animated: true)
        
    }
    @IBAction func onCancel(_ sender: UIBarButtonItem) {
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onTick(_ sender: UIBarButtonItem) {
        
        dismiss(animated: true, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
