//
//  AddGlucoseModalViewController.swift
//  PHR_Project
//
//  Created by Sushant Pulipati on 10/12/25.
//

import UIKit

class AddGlucoseModalViewController: UIViewController {

    @IBOutlet weak var glucoseView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        glucoseView.addRoundedCorner()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func doneModalButton(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func closeModalButton(_ sender: Any) {
        dismiss(animated: true)
    }
}
