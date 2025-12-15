//
//  FamilyMemberViewController.swift
//  PHR_Project
//
//  Created by SDC_USER on 25/11/25.
//

import UIKit

class FamilyMemberViewController: UIViewController {
    
    var familyMember: FamilyMember?

    @IBOutlet weak var pfpImage: UIImageView!
    
    @IBOutlet weak var memberName: UILabel!
    
    @IBOutlet weak var docButton: UIButton!
    
    @IBOutlet weak var mealButton: UIButton!
    
    @IBOutlet weak var symptomLogButton: UIButton!
    
    @IBOutlet weak var trendButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        pfpImage.addFullRoundedCorner()
        
        memberName.text = familyMember?.name ?? "No Name"
    //   docButton.addRoundedCorner()
    //   docButton.applyLiquidGlassEffect()
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
