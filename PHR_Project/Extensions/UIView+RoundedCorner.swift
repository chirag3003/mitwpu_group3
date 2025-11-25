import UIKit

extension UIView{
    func addRoundedCorner(radius: CGFloat = 30){
        layer.cornerRadius = radius
        layer.masksToBounds = true
    }
}
