import UIKit

class FamilyHeaderView: UICollectionReusableView {

    static let identifier = "FamilyHeaderView"

    // MARK: - UI Components

    private let mainAvatar: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = .systemGray5
        iv.contentMode = .scaleAspectFill
        iv.image =
            UIImage(named: "WhatsApp Image 2025-12-15 at 17.09.58")
            ?? UIImage(systemName: "person.crop.circle.fill")
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.setTitleFont()
        label.text = "Your Family"  // Matches design bold font
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Layout

    private func setupUI() {
        addSubview(mainAvatar)
        addSubview(titleLabel)

        NSLayoutConstraint.activate([
            // Main Pfp (Top Center)
            mainAvatar.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            mainAvatar.centerXAnchor.constraint(equalTo: centerXAnchor),
            mainAvatar.widthAnchor.constraint(equalToConstant: 120),
            mainAvatar.heightAnchor.constraint(equalToConstant: 120),

            // Title "Your Family"
            titleLabel.topAnchor.constraint(
                equalTo: mainAvatar.bottomAnchor,
                constant: 20
            ),
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.bottomAnchor.constraint(
                equalTo: bottomAnchor,
                constant: -20
            ),

        ])
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        // Circle styling
        mainAvatar.layer.cornerRadius = mainAvatar.frame.width / 2

    }
}
