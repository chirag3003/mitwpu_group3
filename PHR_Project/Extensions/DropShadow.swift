//
//  DropShadow.swift
//  PHR_Project
//
//  Created by Sushant Pulipati on 28/11/25.
//
import UIKit


extension UIView {
    
    func addDropShadow(
            color: UIColor = .black,
            opacity: Float = UIConstants.Shadow.mediumOpacity,
            offset: CGSize = UIConstants.Shadow.mediumOffset,
            radius: CGFloat = UIConstants.Shadow.defaultRadius
        ) {
            self.layer.shadowColor = color.cgColor
            self.layer.shadowOpacity = opacity
            self.layer.shadowOffset = offset
            self.layer.shadowRadius = radius
            self.layer.masksToBounds = false
        }
    
    }
