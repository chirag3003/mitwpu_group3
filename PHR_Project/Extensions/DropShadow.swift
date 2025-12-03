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
            opacity: Float = 0.15,
            offset: CGSize = CGSize(width: 0, height: 3),
            radius: CGFloat = 6
        ) {
            self.layer.shadowColor = color.cgColor
            self.layer.shadowOpacity = opacity
            self.layer.shadowOffset = offset
            self.layer.shadowRadius = radius
            self.layer.masksToBounds = false
        }
    
    }
