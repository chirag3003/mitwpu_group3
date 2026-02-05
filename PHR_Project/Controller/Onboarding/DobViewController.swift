import UIKit

class DobViewController: UIViewController {

    @IBOutlet weak var dobValue: UIDatePicker!
    
    // Receive data from previous screen
    var profileDataArray: [String: Any] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print("Received data:", profileDataArray)

        dobValue.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
    }
    
    // MARK: - Actions
    @objc private func dateChanged(_ sender: UIDatePicker) {
        let selectedDate = sender.date
        
        print("Selected date: \(formatDate(selectedDate))")
        
        if let age = calculateAge(from: selectedDate) {
            print("Age: \(age) years")
        }
    }
    
    @IBAction func nextBtn(_ sender: Any) {
        if validateDate() {
            saveDataToArray()
            printCurrentData()
        }
    }

    
    private func validateDate() -> Bool {
        let selectedDate = dobValue.date
        let today = Date()
        let calendar = Calendar.current
        
        // Strip time components - compare only dates
        let selectedDay = calendar.startOfDay(for: selectedDate)
        let todayDay = calendar.startOfDay(for: today)
        
        // Check if selected date is after today
        if selectedDay > todayDay {
            showAlert(title: "Error", message: "DOB cannot be in the future.")
            return false
        }
        
        // Check if selected date is today
        if selectedDay == todayDay {
            showAlert(title: "Error", message: "Can't select today as date of birth.")
            return false
        }
        
        // Check if date is more than 120 years ago
        if let maxAge = calendar.date(byAdding: .year, value: -120, to: today) {
            let maxAgeDay = calendar.startOfDay(for: maxAge)
            if selectedDay < maxAgeDay {
                showAlert(title: "Error", message: "Please enter a valid date of birth.")
                return false
            }
        }
        
        return true
    }
    
    // MARK: - Data Management
    private func saveDataToArray() {
        profileDataArray["dob"] = dobValue.date
        
        // Optionally also save age
        if let age = calculateAge(from: dobValue.date) {
            profileDataArray["age"] = age
        }
    }
    
    private func printCurrentData() {
        print("========== Profile Data ==========")
        print("First Name: \(profileDataArray["firstName"] ?? "")")
        print("Last Name: \(profileDataArray["lastName"] ?? "")")
        print("Gender: \(profileDataArray["sex"] ?? "")")
        print("DOB: \(formatDate(dobValue.date))")
        if let age = profileDataArray["age"] as? Int {
            print("Age: \(age) years")
        }
        print("==================================")
    }
    
    // MARK: - Helper Methods
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    private func calculateAge(from date: Date) -> Int? {
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: date, to: Date())
        return ageComponents.year
    }
    
    // MARK: - Public Methods
    
    /// Get the selected date
    func getSelectedDate() -> Date {
        return dobValue.date
    }
    
    /// Get the selected date as a formatted string
    func getFormattedDate() -> String {
        return formatDate(dobValue.date)
    }
    
    /// Get the age based on the selected date
    func getAge() -> Int? {
        return calculateAge(from: dobValue.date)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Pass the updated array to the next screen (DiabetesTypeViewController)
        if let heightVC = segue.destination as? HeightScaleViewController {
            heightVC.profileDataArray = profileDataArray
        }
    }
}

