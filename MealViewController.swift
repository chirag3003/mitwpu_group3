//
//  MealViewController.swift
//  PHR_Project
//
//  Created by Sushant Pulipati on 25/11/25.
//

import UIKit

class MealViewController: UIViewController {
    @IBOutlet weak var headerView: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        headerView.text = "Your Meals"
        headerView.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        
    }
   
    }
