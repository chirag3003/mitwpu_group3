//
//  AddSymptomTableViewController.swift
//  PHR_Project
//
//  Created by SDC_USER on 03/12/25.
//

import UIKit

class AddSymptomTableViewController: UITableViewController {

    // MARK: - Outlets
    @IBOutlet weak var typeButton: UIButton!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var intensityButton: UIButton!
    @IBOutlet weak var notesTextView: UITextView!
    @IBOutlet weak var placeholderLabel: UILabel!
    @IBOutlet weak var cameraImageView: UIImageView!
    @IBOutlet var addSymptomTableView: UITableView!
    
    
    var selectedType: String?
    var selectedIntensity: String?
    var selectedImage: UIImage?
    
    private let symptomsOptions = [
        "Migraine", "Fatigue", "Dizziness", "Nausea", "Polyuria",
        "Blurred Vision", "Irritability", "Extreme Hunger", "Dry Mouth",
    ]

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // 1. Setup Menus
        setupTypeMenu()
        setupIntensityMenu()

        // 2. Setup Image Tap
        setupImageGesture()

        // 3. Notes Delegate
        notesTextView.delegate = self

        // Optional: Remove extra lines if any
        tableView.separatorStyle = .singleLine
        
        //addSymptomTableView.addRoundedCorner()
        addSymptomTableView.backgroundColor = .systemGray6
    }

    // MARK: - Setup Functions

    func setupTypeMenu() {
        
        var actions: [UIAction] = []

        for option in symptomsOptions {
            actions.append(
                UIAction(title: option) { [weak self] action in
                    self?.selectedType = action.title
                    self?.typeButton.setTitle(action.title, for: .normal)
                }
            )
        }
        typeButton.menu = UIMenu(children: actions)
        typeButton.showsMenuAsPrimaryAction = true
    }

    func setupIntensityMenu() {
        let options = ["Low", "Medium", "High"]
        var actions: [UIAction] = []

        for option in options {
            actions.append(
                UIAction(title: option) { [weak self] action in
                    self?.selectedIntensity = action.title
                    self?.intensityButton.setTitle(action.title, for: .normal)
                }
            )
        }
        intensityButton.menu = UIMenu(children: actions)
        intensityButton.showsMenuAsPrimaryAction = true
    }

    func setupImageGesture() {
        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(handleImageTap)
        )
        cameraImageView.isUserInteractionEnabled = true
        cameraImageView.addGestureRecognizer(tap)
    }

    // MARK: - Actions

    @objc func handleImageTap() {
        let picker = UIImagePickerController()
        // Check if camera is available (use .photoLibrary for Simulator)
        picker.sourceType =
            UIImagePickerController.isSourceTypeAvailable(.camera)
            ? .camera : .photoLibrary
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true)
    }

    @IBAction func cancelButtonTapped(_ sender: Any) {

        dismiss(animated: true)
    }

    @IBAction func saveButtonTapped(_ sender: Any) {
        guard let type = selectedType, let intensity = selectedIntensity else {
            // Show simple alert
            let alert = UIAlertController(
                title: "Missing Info",
                message: "Please select Type and Intensity",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }

        // Combine Date and Time into a single Foundation.Date
        let calendar = Calendar.current

        // Date components (year, month, day from datePicker)
        var dateComponents = calendar.dateComponents(
            [.year, .month, .day],
            from: datePicker.date
        )
        // Time components (hour, minute from timePicker)
        let timeComponents = calendar.dateComponents(
            [.hour, .minute],
            from: timePicker.date
        )
        dateComponents.hour = timeComponents.hour
        dateComponents.minute = timeComponents.minute

        // Build the final Date for dateRecorded
        let recordedDate: Foundation.Date =
            calendar.date(from: dateComponents) ?? datePicker.date

        //Creating new symptom
        let newSymptom = Symptom(
            id: UUID(),
            symptomName: type,
            intensity: intensity,
            dateRecorded: recordedDate,
            notes: notesTextView.text ?? "",
            time: timeComponents
        )
        SymptomService.shared.addSymptom(newSymptom)
        
        // Dismiss after saving
        dismiss(animated: true)
    }

    // MARK: - Table View Config (Optional adjustments)
    // Since we use Static Cells, we don't need numberOfRows or cellForRowAt!

    // We can use this to make the header/footer spacing cleaner if needed
    override func tableView(
        _ tableView: UITableView,
        heightForHeaderInSection section: Int
    ) -> CGFloat {
        return 10  // Space between cards
    }
}

// MARK: - Extensions

extension AddSymptomTableViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
}

extension AddSymptomTableViewController: UIImagePickerControllerDelegate,
    UINavigationControllerDelegate
{
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey:
            Any]
    ) {

        if let image = info[.editedImage] as? UIImage ?? info[.originalImage]
            as? UIImage
        {
            selectedImage = image
            cameraImageView.image = image
            cameraImageView.contentMode = .scaleAspectFill
            cameraImageView.layer.cornerRadius = 8
            cameraImageView.clipsToBounds = true
        }
        dismiss(animated: true)
    }
    


}
