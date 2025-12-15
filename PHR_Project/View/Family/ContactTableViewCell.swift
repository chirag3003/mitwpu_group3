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
        // Assuming contact.image is a URL string or image name
        pfpImage.image = UIImage(named: "WhatsApp Image 2025-12-15 at 17.09.58")
        
        pfpImage.addFullRoundedCorner()
    }

}
