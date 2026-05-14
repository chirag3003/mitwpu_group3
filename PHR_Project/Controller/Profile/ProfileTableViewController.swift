import UIKit

class ProfileTableViewController: UITableViewController {

    // MARK: - Outlets

    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!

    @IBOutlet weak var notificationSwitch: UISwitch!
    @IBOutlet weak var logoutButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        profileImage.addFullRoundedCorner()

        profileImage.contentMode = .scaleAspectFill
        logoutButton.tintColor = .systemRed
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
        if let photoData = profile.profileImage, !photoData.isEmpty {
            profileImage.setImageFromURL(url: photoData)
        } else {
            profileImage.image = UIImage(systemName: "person.circle.fill")
            profileImage.tintColor = .systemGray4
        }

        notificationSwitch.isOn = ReminderNotificationService.shared.isEnabled()
    }

    // MARK: - Actions

    @IBAction func onLogOut(_ sender: UIButton) {
        let alert = UIAlertController(
            title: "Logout?",
            message: "Are you sure you want to log out of your account?",
            preferredStyle: .actionSheet
        )

        let logoutAction = UIAlertAction(title: "Logout", style: .destructive) { [weak self] _ in
            AuthService.shared.logout()
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let onboarding = storyboard.instantiateViewController(
                withIdentifier: "onboardingNavController"
            )
            self?.resetRootViewController(to: onboarding)
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)

        alert.addAction(logoutAction)
        alert.addAction(cancelAction)

        // iPad support
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = sender
            popoverController.sourceRect = sender.bounds
        }

        present(alert, animated: true)
    }
    @IBAction func onDoneClick(_ sender: Any) {
        self.dismiss(animated: true)
    }

    private func resetRootViewController(
        to rootViewController: UIViewController
    ) {
        guard
            let windowScene = UIApplication.shared.connectedScenes.first
                as? UIWindowScene,
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

    @IBAction func onNotificationSwitchChange(_ sender: Any) {
        let isOn = notificationSwitch.isOn

        if isOn {
            ReminderNotificationService.shared.requestAuthorization {
                [weak self] granted in
                guard let self = self else { return }

                if granted {
                    ReminderNotificationService.shared.setEnabled(true)
                    ReminderNotificationService.shared
                        .scheduleDefaultReminders()
                } else {
                    self.notificationSwitch.setOn(false, animated: true)
                    ReminderNotificationService.shared.setEnabled(false)
                    ReminderNotificationService.shared.cancelAllReminders()
                    self.showNotificationPermissionAlert()
                }
            }
        } else {
            ReminderNotificationService.shared.setEnabled(false)
            ReminderNotificationService.shared.cancelAllReminders()
        }
    }

    private func showNotificationPermissionAlert() {
        let alert = UIAlertController(
            title: "Notifications Disabled",
            message:
                "Enable notifications in Settings to receive meal and water reminders.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(
            UIAlertAction(title: "Open Settings", style: .default) { _ in
                guard let url = URL(string: UIApplication.openSettingsURLString)
                else { return }
                UIApplication.shared.open(url)
            }
        )

        present(alert, animated: true)
    }
}
