import UIKit

class ProfileTableViewController: UITableViewController {

    // MARK: - Outlets

    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!

    @IBOutlet weak var logoutButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        profileImage.addFullRoundedCorner()

        profileImage.contentMode = .scaleAspectFill
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Fetch the latest profile data every time this screen appears
        let profile = ProfileService.shared.getProfile()

        // Set the Name
        let fullName = "\(profile.firstName) \(profile.lastName)"
            .trimmingCharacters(in: .whitespaces)
        userNameLabel.text = fullName.isEmpty ? "User Name" : fullName

        // Set the Profile Image!
        if let photoData = profile.imageData,
            let savedImage = UIImage(data: photoData)
        {
            profileImage.image = savedImage
            profileImage.contentMode = .scaleAspectFill
        } else {
            // If they haven't picked a photo yet, reset it to your hardcoded image.
            // Replace "YourDefaultImageName" with the actual name of the image in your Assets folder!
            profileImage.image = UIImage(
                named: "WhatsApp Image 2025-12-15 at 17.09.58"
            )
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        if section == 0 {
            return 4
        } else {
            return 1
        }
    }

    // MARK: - Actions

    @IBAction func onLogOut(_ sender: UIButton) {
        AuthService.shared.logout()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let onboarding = storyboard.instantiateViewController(
            withIdentifier: "onboardingNavController"
        )
        resetRootViewController(to: onboarding)
    }
    @IBAction func onDoneClick(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    private func resetRootViewController(to rootViewController: UIViewController) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first
        else { return }
        UIView.transition(
            with: window,
            duration: 0.4,
            options: .transitionCrossDissolve
        ) {
            window.rootViewController = rootViewController
        }
    }

}
