import UIKit


class MealItemCollectionView: UICollectionView {
    
    override var contentSize: CGSize {
        didSet {
            // Whenever content gets added/removed, update the view's size
            invalidateIntrinsicContentSize()
        }
    }
    
    override var intrinsicContentSize: CGSize {
        // Tell the Auto Layout system that the height is equal to the content
        layoutIfNeeded()
        return CGSize(width: UIView.noIntrinsicMetric, height: contentSize.height)
    }
}
