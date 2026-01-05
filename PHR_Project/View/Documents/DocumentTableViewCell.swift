//
//  DocumentTableViewCell.swift
//  PHR_Project
//
//  Created by SDC-USER on 26/11/25.
//

import UIKit

class DocumentTableViewCell: UITableViewCell {

    @IBOutlet weak var folderImage: UIImageView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var doctorLabel: UILabel!
    
    @IBOutlet weak var updatedLable: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        documentButton.addRoundedCorner(radius:30)
        mainView.addRoundedCorner(radius: 15)
        folderImage.addRoundedCorner(radius:16)
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func configure(with documentData: documentsModel) {
        
        doctorLabel.text = documentData.title
        updatedLable.text = "Modified: \(documentData.lastUpdatedAt)"
        
       
        
        
    }
    
    

}
