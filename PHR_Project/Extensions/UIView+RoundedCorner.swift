import UIKit

extension UIView{
    func addRoundedCorner(radius: CGFloat = 30){
        layer.cornerRadius = radius
        self.clipsToBounds = true
        layer.masksToBounds = true
    }
    
    func addFullRoundedCorner(){
        layer.cornerRadius = self.frame.height / 2
        layer.masksToBounds = true
        self.clipsToBounds = true
    }
}
