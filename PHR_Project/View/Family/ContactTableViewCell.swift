import UIKit

class ContactTableViewCell: UITableViewCell {

    // MARK: - Outlets

    @IBOutlet weak var pfpImage: UIImageView!
    @IBOutlet weak var numLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

    }

    override func setSelected(_ selected: Bool, animated: Bool) {

        super.setSelected(selected, animated: animated)

    }

    func configure(with contact: Contact) {
        nameLabel.text = contact.name
        numLabel.text = contact.phoneNum

        // Use contact's photo if available, otherwise use default

        if let imageData = contact.imageData,
            let image = UIImage(data: imageData)
        {
            pfpImage.image = image
        } else {
            pfpImage.image = UIImage(systemName: "person.circle")
        }

        pfpImage.addFullRoundedCorner()
    }

}
