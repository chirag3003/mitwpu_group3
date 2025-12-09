//
//  GlucoseViewController.swift
//  PHR_Project
//
//  Created by Sushant Pulipati on 09/12/25.
//

import UIKit

class GlucoseViewController: UIViewController {

    @IBOutlet weak var graphImage: UIImageView!
    @IBOutlet weak var graphView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        graphView.addRoundedCorner()
        graphImage.addRoundedCorner()

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

}
