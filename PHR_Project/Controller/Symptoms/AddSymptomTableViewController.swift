import UIKit

class AddSymptomTableViewController: UITableViewController {

    private let symptomsOptions = [
        "Migraine", "Fatigue", "Dizziness", "Nausea", "Polyuria",
        "Blurred Vision", "Irritability", "Swelling", "Extreme Hunger", "Dry Mouth",
        "Sweating",
    ]

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
    var symptomToEdit: Symptom?
    var onSave: (() -> Void)?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Button functions
        setupTypeMenu()
        setupIntensityMenu()
        setupImageGesture()

        // Cosmetic functions
        notesTextView.delegate = self
        setupHideKeyboardOnTap()
        setupTextViewAlignment()
        configureNotesTextViewInsets()
        checkForEditMode()

        //Removing table lines
        tableView.separatorStyle = .singleLine
    }
    
    private func checkForEditMode() {
            if let symptom = symptomToEdit {
                self.title = "Edit Symptom"
                
                // 1. Set Type
                selectedType = symptom.symptomName
                typeButton.setTitle(symptom.symptomName, for: .normal)
                
                // 2. Set Intensity
                selectedIntensity = symptom.intensity
                intensityButton.setTitle(symptom.intensity, for: .normal)
                
                // 3. Set Date
                datePicker.date = symptom.dateRecorded
                
                // 4. Set Time (Reconstruct Date from components)
                let calendar = Calendar.current
                var timeComponents = DateComponents()
                timeComponents.hour = symptom.time.hour
                timeComponents.minute = symptom.time.minute
                if let timeDate = calendar.date(from: timeComponents) {
                    timePicker.date = timeDate
                }
                
                // 5. Set Notes
                notesTextView.text = symptom.notes
                placeholderLabel.isHidden = !(notesTextView.text?.isEmpty ?? true)
                
                // Note: Image handling isn't in your Symptom model provided, so skipping image pre-fill.
            }
        }

    private func configureNotesTextViewInsets() {
        // Cursor Alignment for UITextView
        notesTextView.textContainerInset = UIEdgeInsets(
            top: 0,
            left: 7,
            bottom: 0,
            right: 0
        )
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

    // Dismiss keyboard when tapping outside
    func setupHideKeyboardOnTap() {
        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(handleBackgroundTap)
        )
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc private func handleBackgroundTap() {
        view.endEditing(true)
    }

    // Keep text view and placeholder aligned, set initial placeholder visibility
    func setupTextViewAlignment() {
        notesTextView.textAlignment = .natural
        placeholderLabel.textAlignment = notesTextView.textAlignment
        placeholderLabel.isHidden = !(notesTextView.text?.isEmpty ?? true)
    }

    // MARK: - Actions

    @objc func handleImageTap() {
        let picker = UIImagePickerController()
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
                    self.showAlert(title: "Missing Info", message: "Please select Type and Intensity")
                    return
        }

        // Combine Date and Time
        let calendar = Calendar.current
                var dateComponents = calendar.dateComponents([.year, .month, .day], from: datePicker.date)
                let timeComponents = calendar.dateComponents([.hour, .minute], from: timePicker.date)
                dateComponents.hour = timeComponents.hour
                dateComponents.minute = timeComponents.minute

                let recordedDate: Foundation.Date = calendar.date(from: dateComponents) ?? datePicker.date
                
                self.showLoader(true)

                if var existingSymptom = symptomToEdit {
                    // EDIT MODE
                    existingSymptom.symptomName = type
                    existingSymptom.intensity = intensity
                    existingSymptom.dateRecorded = recordedDate
                    existingSymptom.notes = notesTextView.text ?? ""
                    
                    var newTime = DateComponents()
                    newTime.hour = timeComponents.hour
                    newTime.minute = timeComponents.minute
                    existingSymptom.time = newTime
                    
                    SymptomService.shared.updateSymptom(existingSymptom) { [weak self] result in
                        guard let self = self else { return }
                        DispatchQueue.main.async {
                            self.showLoader(false)
                            switch result {
                            case .success:
                                // NEW: Trigger the refresh in the parent controller
                                self.onSave?()
                                self.dismiss(animated: true)
                            case .failure(let error):
                                self.showAlert(title: "Error", message: "Failed to update: \(error.localizedDescription)")
                            }
                        }
                    }
                } else {
                    // ADD MODE
                    let newSymptom = Symptom(
                        id: UUID(),
                        symptomName: type,
                        intensity: intensity,
                        dateRecorded: recordedDate,
                        notes: notesTextView.text ?? "",
                        time: timeComponents
                    )

                    SymptomService.shared.addSymptom(newSymptom) { [weak self] result in
                        guard let self = self else { return }
                        DispatchQueue.main.async {
                            self.showLoader(false)
                            switch result {
                            case .success:
                                // NEW: Trigger the refresh in the parent controller
                                self.onSave?()
                                self.dismiss(animated: true)
                            case .failure(let error):
                                self.showAlert(title: "Error", message: "Failed to add: \(error.localizedDescription)")
                            }
                        }
                    }
                }
            }

    // MARK: - Table View Config
    override func tableView(
        _ tableView: UITableView,
        heightForHeaderInSection section: Int
    ) -> CGFloat {
        return 10
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
