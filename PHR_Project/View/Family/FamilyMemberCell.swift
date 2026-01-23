import UIKit

class FamilyMemberCell: UICollectionViewCell {
    static let identifier = "FamilyMemberCell"

    override var isHighlighted: Bool {
        didSet {

            let scale: CGFloat = isHighlighted ? 0.90 : 1.0
            let alpha: CGFloat = isHighlighted ? 0.7 : 1.0

            // Spring Animation
            UIView.animate(
                withDuration: 0.5,  // Duration for the spring to settle
                delay: 0,
                usingSpringWithDamping: 0.5,
                initialSpringVelocity: 3,
                options: [.allowUserInteraction, .beginFromCurrentState],
                animations: {
                    self.containerView.transform = CGAffineTransform(
                        scaleX: scale,
                        y: scale
                    )
                    self.containerView.alpha = alpha
                },
                completion: nil
            )
        }
    }

    // MARK: - UI Components

    private let containerView: CircleView = {
        let view = CircleView()  // Custom UIView for circular shape
        view.backgroundColor = .tertiarySystemBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.tintColor = .darkGray
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.clipsToBounds = true
        return iv
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.textColor = .label
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

    // MARK: - Layout Logic

    private func setupUI() {
        contentView.addSubview(containerView)
        containerView.addSubview(imageView)
        contentView.addSubview(nameLabel)

        NSLayoutConstraint.activate([
            // Container (The Circle)
            containerView.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: 4
            ),
            containerView.centerXAnchor.constraint(
                equalTo: contentView.centerXAnchor
            ),
            // So that edges are not touched
            containerView.widthAnchor.constraint(
                equalTo: contentView.widthAnchor,
                multiplier: 0.8
            ),
            // Aspect Ratio for an exact circle
            containerView.heightAnchor.constraint(
                equalTo: containerView.widthAnchor
            ),

            // Image inside Container
            imageView.topAnchor.constraint(equalTo: containerView.topAnchor),
            imageView.leadingAnchor.constraint(
                equalTo: containerView.leadingAnchor
            ),
            imageView.trailingAnchor.constraint(
                equalTo: containerView.trailingAnchor
            ),
            imageView.bottomAnchor.constraint(
                equalTo: containerView.bottomAnchor
            ),

            // Name Label
            nameLabel.topAnchor.constraint(
                equalTo: containerView.bottomAnchor,
                constant: 8
            ),
            nameLabel.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor
            ),
            nameLabel.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor
            ),
            // Using less than or equal ensures text doesn't get cut off if cell is short
            nameLabel.bottomAnchor.constraint(
                lessThanOrEqualTo: contentView.bottomAnchor,
                constant: -4
            ),
        ])
    }

    func configure(with member: FamilyMember) {
        nameLabel.text = member.name
        if member.imageName.hasPrefix("https") {
            imageView.transform = .identity
            imageView.setImageFromURL(url: member.imageName)
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
        } else {
            imageView.image = UIImage(systemName: "person.fill")
            imageView.contentMode = .center
            imageView.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        }
    }
}

class CircleView: UIView {
    override func layoutSubviews() {
        super.layoutSubviews()
        // Size auto reshaping

        self.layer.cornerRadius = self.bounds.height / 2
        self.layer.masksToBounds = true
    }
}
