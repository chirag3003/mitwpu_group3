import UIKit

class ProfileTableViewController: UITableViewController {

    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        profileImage.addFullRoundedCorner()
        
        let profile = ProfileService.shared.getProfile()
        let fullName = "\(profile.firstName) \(profile.lastName)".trimmingCharacters(in: .whitespaces)
        userNameLabel.text = fullName.isEmpty ? "User Name" : fullName
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }

    @IBAction func onDoneClick(_ sender: Any) {
        self.dismiss(animated: true)
    }
    

        
    

}

