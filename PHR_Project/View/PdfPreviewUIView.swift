import PDFKit
import UIKit

class PdfPreviewUIView: UIView {
    var pdfURL: String?
    var pdfView: PDFView?

    func setPdf(url: String) {
        pdfURL = url

        // Create the PDFView if it doesn't exist
        if pdfView == nil {
            pdfView = PDFView(frame: self.bounds)
            pdfView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.addSubview(pdfView!)

            pdfView?.autoScales = true
            pdfView?.displayMode = .singlePageContinuous
            pdfView?.displayDirection = .vertical
        }

        // Load the Document from cloud url
        if url.hasPrefix("http://") || url.hasPrefix("https://") {
            guard let remoteURL = URL(string: url) else { return }
            
            URLSession.shared.dataTask(with: remoteURL) { [weak self] data, _, error in
                guard let data = data, error == nil,
                      let document = PDFDocument(data: data) else { return }
                
                DispatchQueue.main.async {
                    self?.pdfView?.document = document
                }
            }.resume()
        } else {
            // Load the Document from local url
            let fileURL = URL(fileURLWithPath: url)
            if let document = PDFDocument(url: fileURL) {
                pdfView?.document = document
            }
        }
    }
}
