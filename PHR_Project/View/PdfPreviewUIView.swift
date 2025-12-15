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

        // Load the Document
        let fileURL = URL(fileURLWithPath: url)
        if let document = PDFDocument(url: fileURL) {
            pdfView?.document = document
        }
    }
}
