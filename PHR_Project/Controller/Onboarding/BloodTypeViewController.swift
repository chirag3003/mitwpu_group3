//
//  BloodTypeViewController.swift
//  PHR_Project
//
//  Created by Sushant Pulipati on 03/02/26.
//

import UIKit

class BloodTypeViewController: UIViewController {

    @IBOutlet weak var viewOne: UIView!
    @IBOutlet weak var viewTwo: UIView!
    @IBOutlet weak var viewThree: UIView!
    @IBOutlet weak var viewFour: UIView!
    @IBOutlet weak var viewFive: UIView!
    @IBOutlet weak var viewSix: UIView!
    @IBOutlet weak var viewSeven: UIView!
    @IBOutlet weak var viewEight: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewOne.addRoundedCorner(radius: 10)
        viewTwo.addRoundedCorner(radius: 10)
        viewThree.addRoundedCorner(radius: 10)
        viewFour.addRoundedCorner(radius: 10)
        viewFive.addRoundedCorner(radius: 10)
        viewSix.addRoundedCorner(radius: 10)
        viewSeven.addRoundedCorner(radius: 10)
        viewEight.addRoundedCorner(radius: 10)

        // Do any additional setup after loading the view.
    }
    

}
