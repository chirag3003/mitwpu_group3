
import UIKit

class FamilyMemberCell: UICollectionViewCell {
    static let identifier = "FamilyMemberCell"
    
    // MARK: - UI Components
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6 // Light gray background for avatar
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.tintColor = .darkGray // Fallback color
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.clipsToBounds = true
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
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout Logic
    private func setupUI() {
        contentView.addSubview(containerView)
        containerView.addSubview(imageView)
        contentView.addSubview(nameLabel)
        
        NSLayoutConstraint.activate([
            // 1. Container (The Circle)
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            containerView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            containerView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.85), // 85% of cell width
            containerView.heightAnchor.constraint(equalTo: containerView.widthAnchor), // Make it square
            
            // 2. Image inside Container
            imageView.topAnchor.constraint(equalTo: containerView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            
            // 3. Name Label
            nameLabel.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 10),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            nameLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Dynamically make it round based on the actual size
        containerView.layer.cornerRadius = containerView.frame.size.width / 2
        imageView.layer.cornerRadius = imageView.frame.width / 2
    }
    
    // MARK: - Configure
    func configure(with member: FamilyMember) {
        nameLabel.text = member.name
        
        // Logic: If image asset exists, use it. If not, use SF Symbol.
        if let image = UIImage(named: member.imageName) {
            imageView.image = image
        } else {
            // Placeholder logic
            imageView.image = UIImage(systemName: "person.fill")
            // Make icon smaller inside the circle if it's a symbol
            imageView.contentMode = .center
            imageView.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        }
    }
}
