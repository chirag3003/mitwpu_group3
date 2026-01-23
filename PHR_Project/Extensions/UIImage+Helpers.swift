import UIKit

extension UIImageView {

    func setImageFromURL(url: String) {
        guard let url = URL(string: url) else { return }
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let data = data, let image = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                self?.image = image
            }
        }.resume()
    }
    
}