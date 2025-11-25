
import UIKit

class FamilyHeaderView: UICollectionReusableView {
    static let identifier = "FamilyHeaderView"
    
    // MARK: - UI Components
    private let mainAvatar: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = .systemGray5
        iv.contentMode = .scaleAspectFill
        iv.image = UIImage(named: "profile") ?? UIImage(systemName: "person.crop.circle.fill") // Use your 'profile' asset here
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Your Family"
        label.font = .systemFont(ofSize: 28, weight: .heavy) // Matches design bold font
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // The Circular Add Button
//    let addButton: UIButton = {
//        let btn = UIButton(type: .system)
//        let config = UIImage.SymbolConfiguration(weight: .bold)
//        btn.setImage(UIImage(systemName: "plus", withConfiguration: config), for: .normal)
//        btn.backgroundColor = .white
//        btn.tintColor = .black
//        
//        // Shadow
//        btn.layer.shadowColor = UIColor.black.cgColor
//        btn.layer.shadowOpacity = 0.1
//        btn.layer.shadowOffset = CGSize(width: 0, height: 2)
//        btn.layer.shadowRadius = 4
//        btn.translatesAutoresizingMaskIntoConstraints = false
//        return btn
//    }()
    
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
//        addSubview(addButton)
        
        NSLayoutConstraint.activate([
            // 1. Main Avatar (Top Center)
            mainAvatar.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            mainAvatar.centerXAnchor.constraint(equalTo: centerXAnchor),
            mainAvatar.widthAnchor.constraint(equalToConstant: 120),
            mainAvatar.heightAnchor.constraint(equalToConstant: 120),
            
            // 2. Title "Your Family"
            titleLabel.topAnchor.constraint(equalTo: mainAvatar.bottomAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20),
            
            // 3. Add Button (Top Right)
            // Positioned relative to the header view's right edge
//            addButton.topAnchor.constraint(equalTo: topAnchor, constant: 30),
//            addButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
//            addButton.widthAnchor.constraint(equalToConstant: 44),
//            addButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Circle styling
        mainAvatar.layer.cornerRadius = mainAvatar.frame.width / 2
//        addButton.layer.cornerRadius = addButton.frame.width / 2
    }
}
