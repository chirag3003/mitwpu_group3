import UIKit

class FamilyMemberCell: UICollectionViewCell {
    static let identifier = "FamilyMemberCell"
    
    override var isHighlighted: Bool {
        didSet {
            // 1. Make the shrinkage more obvious (0.90 instead of 0.95)
            let scale: CGFloat = isHighlighted ? 0.90 : 1.0
            let alpha: CGFloat = isHighlighted ? 0.7 : 1.0
            
            // 2. Use Spring Animation for better visibility on quick taps
            UIView.animate(
                withDuration: 0.5, // Longer duration for the spring to settle
                delay: 0,
                usingSpringWithDamping: 0.5, // 0.0 = very bouncy, 1.0 = stiff
                initialSpringVelocity: 3,
                options: [.allowUserInteraction, .beginFromCurrentState],
                animations: {
                    self.containerView.transform = CGAffineTransform(scaleX: scale, y: scale)
                    self.containerView.alpha = alpha
                },
                completion: nil
            )
        }
    }
    // MARK: - UI Components

    // CHANGED: Use CircleView instead of UIView
    private let containerView: CircleView = {
        let view = CircleView()  // <--- Use custom class
        view.backgroundColor = .tertiarySystemBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.tintColor = .darkGray
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.clipsToBounds = true  // Ensure image respects the container's bounds
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
            // 1. Container (The Circle)
            containerView.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: 4
            ),
            containerView.centerXAnchor.constraint(
                equalTo: contentView.centerXAnchor
            ),
            // Use 0.8 multiplier to ensure it doesn't touch edges
            containerView.widthAnchor.constraint(
                equalTo: contentView.widthAnchor,
                multiplier: 0.8
            ),
            // Aspect Ratio 1:1 is CRITICAL for a perfect circle
            containerView.heightAnchor.constraint(
                equalTo: containerView.widthAnchor
            ),

            // 2. Image inside Container (Fill completely)
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

            // 3. Name Label
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

    // MARK: - CLEANUP
    // Remove the override layoutSubviews() from here completely.
    // The CircleView class handles it now.

    func configure(with member: FamilyMember) {
        nameLabel.text = member.name

        if let image = UIImage(named: member.imageName) {
            imageView.image = image
            imageView.transform = .identity
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
        // This ensures that WHENEVER this view changes size, it recalculates the circle
        self.layer.cornerRadius = self.bounds.height / 2
        self.layer.masksToBounds = true
    }
}
