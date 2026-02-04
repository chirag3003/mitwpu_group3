//
//  DiabetesTypeViewController.swift
//  PHR_Project
//
//  Created by Sushant Pulipati on 03/02/26.
//

import UIKit

class DiabetesTypeViewController: UIViewController {

    @IBOutlet weak var viewOne: UIView!
    @IBOutlet weak var viewTwo: UIView!
    @IBOutlet weak var viewThree: UIView!
    @IBOutlet weak var viewFour: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewOne.addRoundedCorner(radius: 10)
        viewTwo.addRoundedCorner(radius: 10)
        viewThree.addRoundedCorner(radius: 10)
        viewFour.addRoundedCorner(radius: 10)

    }
 

}
