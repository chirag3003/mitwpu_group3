import UIKit

class FamilyMemberCell: UICollectionViewCell {
    static let identifier = "FamilyMemberCell"
    
    // MARK: - UI Components
    
    // CHANGED: Use CircleView instead of UIView
    private let containerView: CircleView = {
        let view = CircleView() // <--- Use custom class
        view.backgroundColor = .systemGray6
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.tintColor = .darkGray
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.clipsToBounds = true // Ensure image respects the container's bounds
        return iv
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.textColor = .black
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
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            containerView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            // Use 0.8 multiplier to ensure it doesn't touch edges
            containerView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.8),
            // Aspect Ratio 1:1 is CRITICAL for a perfect circle
            containerView.heightAnchor.constraint(equalTo: containerView.widthAnchor),
            
            // 2. Image inside Container (Fill completely)
            imageView.topAnchor.constraint(equalTo: containerView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            
            // 3. Name Label
            nameLabel.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            // Using less than or equal ensures text doesn't get cut off if cell is short
            nameLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -4)
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
