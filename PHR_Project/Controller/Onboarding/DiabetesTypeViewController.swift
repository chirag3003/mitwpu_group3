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
    
    // MARK: - Properties
    // Receive data from previous screen
    var profileDataArray: [String: Any] = [:]
    
    private var selectedView: UIView?
    private var selectedDiabetesType: String?
    
    private let unselectedColor = UIColor(red: 189/255, green: 215/255, blue: 238/255, alpha: 1.0) // #BDD7EE
    private let selectedColor = UIColor(red: 74/255, green: 144/255, blue: 226/255, alpha: 1.0) // #4A90E2

    enum DiabetesType: String {
        case type1 = "Type 1"
        case type2 = "Type 2"
        case gestational = "Gestational"
        case pre = "Pre"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Print received data from previous screen
        print("Received data on diabetes page:", profileDataArray)
        
        setupUI()
        setupCardViews()
    }
    
    // MARK: - Setup
    private func setupUI() {
        viewOne.addRoundedCorner(radius: 10)
        viewTwo.addRoundedCorner(radius: 10)
        viewThree.addRoundedCorner(radius: 10)
        viewFour.addRoundedCorner(radius: 10)
    }
    
    private func setupCardViews() {
        let cards = [viewOne, viewTwo, viewThree, viewFour]
        
        for card in cards {
            guard let card = card else { continue }
            card.backgroundColor = unselectedColor
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(cardTapped(_:)))
            card.addGestureRecognizer(tapGesture)
            card.isUserInteractionEnabled = true
        }
    }
    
    // MARK: - Actions
    @objc private func cardTapped(_ gesture: UITapGestureRecognizer) {
        guard let tappedCard = gesture.view else { return }
        
        // Deselect if tapping the same card
        if selectedView == tappedCard {
            deselectCard(tappedCard)
            selectedView = nil
            selectedDiabetesType = nil
            return
        }
        
        // Deselect previous
        if let previousCard = selectedView {
            deselectCard(previousCard)
        }
        
        // Select new
        selectCard(tappedCard)
        selectedView = tappedCard
        
        let type = getSelectedType(for: tappedCard)
        selectedDiabetesType = type?.rawValue
        print("Selected diabetes type: \(selectedDiabetesType ?? "None")")
    }
    
    @IBAction func nextBtn(_ sender: Any) {
        if selectedDiabetesType != nil {
            saveDataToArray()
            printCurrentData()
            // Segue happens via storyboard or manual trigger
            // self.performSegue(withIdentifier: "toHeightVC", sender: self)
        } else {
            // Optional: Show alert to select a type
            print("Please select a diabetes type")
        }
    }
    
    // MARK: - Data Management
    private func saveDataToArray() {
        profileDataArray["diabetesType"] = selectedDiabetesType ?? "None"
    }
    
    private func printCurrentData() {
        print("========== Profile Data ==========")
        print("First Name: \(profileDataArray["firstName"] ?? "")")
        print("Last Name: \(profileDataArray["lastName"] ?? "")")
        print("Gender: \(profileDataArray["sex"] ?? "")")
        print("DoB: \(profileDataArray["dob"] ?? "")")
        print("Age: \(profileDataArray["age"] ?? "")")
        print("Height: \(profileDataArray["height"] ?? 0) cm")
        print("Weight: \(profileDataArray["weight"] ?? 0) kg")
        print("Diabetes Type: \(profileDataArray["diabetesType"] ?? "")")
        print("==================================")
    }
    
    // MARK: - Selection Logic Helpers
    private func selectCard(_ card: UIView) {
        UIView.animate(withDuration: 0.3) {
            card.backgroundColor = self.selectedColor
        }
        changeLabelColor(in: card, to: .white)
    }
    
    private func deselectCard(_ card: UIView) {
        UIView.animate(withDuration: 0.3) {
            card.backgroundColor = self.unselectedColor
        }
        changeLabelColor(in: card, to: .black) // Adjust to your preferred unselected label color
    }
    
    private func changeLabelColor(in view: UIView, to color: UIColor) {
        for subview in view.subviews {
            if let label = subview as? UILabel {
                label.textColor = color
            }
        }
    }
    
    private func getSelectedType(for card: UIView) -> DiabetesType? {
        switch card {
        case viewOne:   return .type1
        case viewTwo:   return .type2
        case viewThree: return .gestational
        case viewFour:  return .pre
        default:        return nil
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Pass the updated array to the next screen (e.g., HeightScaleViewController)
        if let bloodTypeVC = segue.destination as? BloodTypeViewController {
            bloodTypeVC.profileDataArray = profileDataArray
        }
    }
}
