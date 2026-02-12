//
//  AddMealModalViewController.swift
//  PHR_Project
//
//  Created by Sushant Pulipati on 09/12/25.
//

import UIKit


class AddMealModalViewController: UITableViewController {

    // MARK: Outlets
    @IBOutlet weak var mealName: UITextField!
    @IBOutlet var addMealTableView: UITableView!
    @IBOutlet weak var mealMenu: UIButton!
    @IBOutlet weak var qtyStepper: UIStepper!
    @IBOutlet weak var stepperValue: UILabel!
    @IBOutlet weak var mealDate: UIDatePicker!
    @IBOutlet weak var mealTime: UIDatePicker!
    @IBOutlet weak var mealCamera: UIImageView!
    
    // MARK: Properties
    var selectedMeal: String?
    var capturedImage: UIImage?

    
    // MARK: Lifecycle
    //Initial setup when view loads
    override func viewDidLoad() {
        super.viewDidLoad()

        setupMealMenu()
        setupCameraImageView()
        addMealTableView.backgroundColor = .systemGray6
        updateStepperLabel()
    }

    
    // MARK: Setup
    //Configure meal type dropdown menu
    func setupMealMenu() {
        let options = ["Breakfast", "Lunch", "Dinner"]
        var actions: [UIAction] = []

        for option in options {
            actions.append(
                UIAction(title: option) { [weak self] action in
                    self?.selectedMeal = action.title
                    self?.mealMenu.setTitle(action.title, for: .normal)
                }
            )
        }
        mealMenu.menu = UIMenu(children: actions)
        mealMenu.showsMenuAsPrimaryAction = true
    }

    // Configure camera image view for tapping
    func setupCameraImageView() {
        mealCamera.isUserInteractionEnabled = true
        mealCamera.contentMode = .scaleAspectFill
        mealCamera.clipsToBounds = true
        
        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(mealCameraTapped)
        )
        mealCamera.addGestureRecognizer(tapGesture)
    }
    
    // Remove camera indicator after image is captured
    private func removeCameraIndicator() {
        mealCamera.viewWithTag(999)?.removeFromSuperview()
    }
    
    // MARK: Camera Action
    @objc func mealCameraTapped() {
        let customCameraVC = CustomCameraViewController()
        customCameraVC.delegate = self
        customCameraVC.modalPresentationStyle = .fullScreen
        present(customCameraVC, animated: true)
    }

    
    
    // MARK: Stepper Control
    //Update quantity when stepper changes
    @IBAction func stepperValueChanged(_ sender: UIStepper) {
        updateStepperLabel()
    }

    //Display current stepper value
    func updateStepperLabel() {
        stepperValue.text = "\(Int(qtyStepper.value))"
    }

    
    // MARK: Actions
    //Validate inputs and save meal
    @IBAction func doneButton(_ sender: Any) {
        saveMeal()
    }

    //Close modal without saving
    @IBAction func cancelButton(_ sender: Any) {
        dismiss(animated: true)
    }
    
    // MARK: Helper Methods
    
    // Save meal to service
    private func saveMeal(name: String? = nil, type: String? = nil) {
        // Use provided name or get from text field
        let mealName = name ?? mealName.text
        
        // Validate meal name
        guard let validName = mealName, !validName.isEmpty else {
            self.showAlert(
                title: "Missing info",
                message: "Please enter a meal name"
            )
            return
        }

        // Use provided type or get from selected menu
        let mealType = type ?? selectedMeal
        
        // Validate meal type
        guard let validType = mealType else {
            self.showAlert(
                title: "Missing info",
                message: "Please select Meal Type"
            )
            return
        }

        // Format time
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "h:mm a"
        let timeString = timeFormatter.string(from: mealTime.date)

        // Format serving detail
        let qty = Int(qtyStepper.value)
        let detailString = "\(qty) serving(s)"

        // Determine image name
        let imageName: String
        if let capturedImg = capturedImage {
            // Save image and get identifier
            imageName = saveImageToDisk(capturedImg)
        } else {
            // Use default image based on meal type
            imageName = validType == "Breakfast" ? "coffee" : "dal"
        }

        // Create meal object
        let newMeal = Meal(
            id: UUID(),
            name: validName,
            detail: detailString,
            time: timeString,
            image: imageName,
            type: validType,
            dateRecorded: mealDate.date,
            calories: 0,
            protein: 0,
            carbs: 0,
            fiber: 0,
            addedBy: "Self",
            notes: nil
        )

        // Save meal
        MealService.shared.addMeal(newMeal)

        // Close modal
        dismiss(animated: true)
    }
    
    // Save captured image to disk and return filename
    private func saveImageToDisk(_ image: UIImage) -> String {
        let filename = "meal_\(UUID().uuidString).jpg"
        
        guard let documentsDirectory = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first else {
            return "dal" // Fallback to default
        }
        
        let fileURL = documentsDirectory.appendingPathComponent(filename)
        
        if let data = image.jpegData(compressionQuality: 0.8) {
            do {
                try data.write(to: fileURL)
                return filename
            } catch {
                print("Error saving image: \(error)")
            }
        }
        
        return "dal" // Fallback to default
    }
}


extension AddMealModalViewController: CustomCameraDelegate {
    
    // Handle captured image from camera
    func didCaptureImage(_ image: UIImage) {
        // Store the captured image
        capturedImage = image
        
        // Update the image view
        mealCamera.image = image
        removeCameraIndicator()
        
        // Dismiss camera
        dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            
            // Auto-analyze with AI and save immediately
            self.analyzeImageWithAI(image)
        }
    }
    
    // Handle manual logging (user chose not to use camera)
    func didTapManuallyLog() {
        // Just dismiss the camera since we're already on the manual entry screen
        dismiss(animated: true)
    }
    
    // AI Analysis Integration - Auto-save after analysis
    private func analyzeImageWithAI(_ image: UIImage) {
        // Show loading indicator
        let loadingAlert = UIAlertController(
            title: "Analyzing...",
            message: "Please wait while we analyze your meal",
            preferredStyle: .alert
        )
        present(loadingAlert, animated: true)
        
        MealService.shared.analyzeMeal(image: image) { [weak self] result in
            guard let self = self else { return }
            
            // Dismiss loading
            loadingAlert.dismiss(animated: true) {
                switch result {
                case .success(let analyzedMeal):
                    // Automatically save the analyzed meal and close modal
                    self.saveMeal(name: analyzedMeal.name, type: self.determineMealType())
                    
                case .failure(let error):
                    print("AI Analysis failed: \(error)")
                    
                    // Show error and keep modal open for manual entry
                    self.showAlert(
                        title: "Analysis Failed",
                        message: "Could not identify the meal. Please enter details manually."
                    )
                }
            }
        }
    }
    
    // Determine meal type based on current time
    private func determineMealType() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        
        if hour >= 5 && hour < 11 {
            return "Breakfast"
        } else if hour >= 11 && hour < 16 {
            return "Lunch"
        } else {
            return "Dinner"
        }
    }
}

