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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        pfpImage.addFullRoundedCorner()
        
        memberName.text = familyMember?.name ?? "No Name"
        
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
