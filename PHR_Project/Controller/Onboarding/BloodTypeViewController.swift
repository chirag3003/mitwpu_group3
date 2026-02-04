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
    
    // MARK: - Properties
    // Receive data from previous screen (WeightScaleViewController)
    var profileDataArray: [String: Any] = [:]
    
    private var selectedView: UIView?
    private var selectedBloodType: String?
    
    private let unselectedColor = UIColor(red: 189/255, green: 215/255, blue: 238/255, alpha: 1.0) // #BDD7EE
    private let selectedColor = UIColor(red: 74/255, green: 144/255, blue: 226/255, alpha: 1.0) // #4A90E2
   
    enum BloodType: String {
        case aPositive = "A+"
        case aNegative = "A-"
        case bPositive = "B+"
        case bNegative = "B-"
        case abPositive = "AB+"
        case abNegative = "AB-"
        case oPositive = "O+"
        case oNegative = "O-"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Print received data from all previous screens
        print("Received data at final step:", profileDataArray)
        
        setupUI()
        setupCardViews()
    }
    
    // MARK: - Setup
    private func setupUI() {
        let cards = [viewOne, viewTwo, viewThree, viewFour, viewFive, viewSix, viewSeven, viewEight]
        cards.forEach { $0?.addRoundedCorner(radius: 10) }
    }
    
    private func setupCardViews() {
        let cards = [viewOne, viewTwo, viewThree, viewFour, viewFive, viewSix, viewSeven, viewEight]
        
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
        
        if selectedView == tappedCard {
            deselectCard(tappedCard)
            selectedView = nil
            selectedBloodType = nil
            return
        }
        
        if let previousCard = selectedView {
            deselectCard(previousCard)
        }
        
        selectCard(tappedCard)
        selectedView = tappedCard
        
        let type = getSelectedBloodType(for: tappedCard)
        selectedBloodType = type?.rawValue
        print("Selected blood type: \(selectedBloodType ?? "Unknown")")
    }
    
    @IBAction func finishBtn(_ sender: Any) {
        guard let bloodType = selectedBloodType else {
            print("Please select a blood type before finishing.")
            return
        }
        
        saveDataToArray(type: bloodType)
        finalizeProfile()
    }
    
    // MARK: - Data Management
    private func saveDataToArray(type: String) {
        profileDataArray["bloodType"] = type
    }
    
    private func finalizeProfile() {
        print("!!! FINAL PROFILE DATA SAVED !!!")
        print("--------------------------------")
        profileDataArray.forEach { (key, value) in
            print("\(key): \(value)")
        }
        print("--------------------------------")
        

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
        changeLabelColor(in: card, to: .black)
    }
    
    private func changeLabelColor(in view: UIView, to color: UIColor) {
        for subview in view.subviews {
            if let label = subview as? UILabel {
                label.textColor = color
            }
        }
    }
    
    private func getSelectedBloodType(for card: UIView) -> BloodType? {
        switch card {
        case viewOne:   return .aPositive
        case viewTwo:   return .aNegative
        case viewThree: return .bPositive
        case viewFour:  return .bNegative
        case viewFive:  return .abPositive
        case viewSix:   return .abNegative
        case viewSeven: return .oPositive
        case viewEight: return .oNegative
        default:        return nil
        }
    }
}
