import UIKit

class DobViewController: UIViewController {

    @IBOutlet weak var dobValue: UIDatePicker!
    
    // Receive data from previous screen
    var profileDataArray: [String: Any] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Print received data from previous screen
        print("Received data:", profileDataArray)
        
        // Print initial date
        //print("Initial date: \(formatDate(dobValue.date))")
        
        // Add target to detect date changes
        dobValue.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
    }
    
    // MARK: - Actions
    @objc private func dateChanged(_ sender: UIDatePicker) {
        let selectedDate = sender.date
        
        // Print the selected date in a readable format
        print("Selected date: \(formatDate(selectedDate))")
        
        // Optional: Print age
        if let age = calculateAge(from: selectedDate) {
            print("Age: \(age) years")
        }
    }
    
    @IBAction func nextBtn(_ sender: Any) {
        saveDataToArray()
        printCurrentData()
        // Segue happens automatically via storyboard
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
