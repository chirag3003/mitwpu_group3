import UIKit

extension UIViewController {
    
    // MARK: - Loader
    
    private var loaderTag: Int { 999999 }
    
    func showLoader(_ show: Bool) {
        if show {
            // Avoid adding double loaders
            if view.viewWithTag(loaderTag) != nil { return }
            
            let activityIndicator = UIActivityIndicatorView(style: .large)
            activityIndicator.center = view.center
            activityIndicator.tag = loaderTag
            activityIndicator.hidesWhenStopped = true
            activityIndicator.startAnimating()
            
            // Add background dimming if desired, for now just the spinner
            view.addSubview(activityIndicator)
            view.isUserInteractionEnabled = false
        } else {
            if let loader = view.viewWithTag(loaderTag) as? UIActivityIndicatorView {
                loader.stopAnimating()
                loader.removeFromSuperview()
            }
            view.isUserInteractionEnabled = true
        }
    }
    
    //Keyboard
    @objc func dissmissKeyboard(){
        view.endEditing(true)
    }
    
    func addKeyboardDisapperanceGesture() {
        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(self.dissmissKeyboard)
        )
        view.addGestureRecognizer(tap)
    }
    
    //Alerts
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
