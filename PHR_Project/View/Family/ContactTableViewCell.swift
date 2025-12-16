//
//  ContactTableViewCell.swift
//  PHR_Project
//
//  Created by SDC_USER on 25/11/25.
//

import UIKit

class ContactTableViewCell: UITableViewCell {


    @IBOutlet weak var pfpImage: UIImageView!
    @IBOutlet weak var numLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        
    }
    
    func configure(with contact: Contact) {
        nameLabel.text = contact.name
        numLabel.text = contact.phoneNum
        
        // Use contact's photo if available, otherwise use default
        if let imageData = contact.imageData, let image = UIImage(data: imageData) {
            pfpImage.image = image
        } else {
            pfpImage.image = UIImage(systemName: "person.circle.fill")
        }
        
        pfpImage.addFullRoundedCorner()
    }

}
