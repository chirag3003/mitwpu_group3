import UIKit

class FamilyHeaderView: UICollectionReusableView {

    static let identifier = "FamilyHeaderView"

    // MARK: - UI Components

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.setTitleFont()
        label.text = "Your Family"
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
    
    // MARK: - Configuration
    
    func configure(with familyName: String) {
        titleLabel.text = familyName
    }

    // MARK: - Layout

    private func setupUI() {
        addSubview(titleLabel)

        NSLayoutConstraint.activate([
            // Title pinned to top and bottom with padding
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20)
        ])
    }
}
