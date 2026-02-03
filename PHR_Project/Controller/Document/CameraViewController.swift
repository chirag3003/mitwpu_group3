

import AVFoundation
import UIKit

// Protocol to handle the captured document
protocol CustomDocumentScannerDelegate: AnyObject {
    func didCaptureDocument(_ image: UIImage)
}

class CustomDocumentScannerViewController: UIViewController {

    // Delegates
    weak var delegate: CustomDocumentScannerDelegate?

    // AVFoundation Properties
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer?
    var photoOutput: AVCapturePhotoOutput!

    // MARK: - UI Elements

    //  Top Bar
    private let closeButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)
        button.setImage(
            UIImage(systemName: "xmark.circle.fill", withConfiguration: config),
            for: .normal
        )
        button.tintColor = .systemGray
        return button
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Scan Document"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        return label
    }()

    //  Center Overlay
    private let overlayImageView: UIImageView = {
        // Document icon
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "doc.text.fill")
        imageView.tintColor = .black
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let bracketImageView: UIImageView = {
        // Scan file icon
        let imageView = UIImageView()
        let config = UIImage.SymbolConfiguration(
            pointSize: 200,
            weight: .ultraLight
        )
        imageView.image = UIImage(
            systemName: "viewfinder",
            withConfiguration: config
        )
        imageView.tintColor = UIColor(
            red: 0.4,
            green: 0.7,
            blue: 1.0,
            alpha: 1.0
        )
        return imageView
    }()

    //  Bottom Bar
    private let bottomBarView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()

    private let shutterButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = .white
        button.layer.cornerRadius = 35
        button.layer.borderWidth = 4
        button.layer.borderColor = UIColor.gray.withAlphaComponent(0.5).cgColor
        return button
    }()

    // MARK: -View Lifecycle
    //using this for one-time set up like background colors
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
       
        setupUI()
        setupCamera()
        startCamera()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.layer.bounds
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    // MARK: -Setup Functions
    //Initialize and adding UI components
    private func setupUI() {
        // Add subviews
        view.addSubview(closeButton)
        view.addSubview(titleLabel)
        view.addSubview(bracketImageView)
        view.addSubview(overlayImageView)
        view.addSubview(bottomBarView)
        bottomBarView.addSubview(shutterButton)

        // Add targets
        closeButton.addTarget(
            self,
            action: #selector(didTapClose),
            for: .touchUpInside
        )
        shutterButton.addTarget(
            self,
            action: #selector(didTapShutter),
            for: .touchUpInside
        )

        // Disable Auto Layout masks
        [
            closeButton, titleLabel, bracketImageView, overlayImageView,
            bottomBarView, shutterButton,
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        // Constraints  forb CustomDocumentScannerViewController's
        NSLayoutConstraint.activate([
            // Top Bar
            //Close Button
            closeButton.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: 16
            ),
            closeButton.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 16
            ),
            //title Label
            titleLabel.centerYAnchor.constraint(
                equalTo: closeButton.centerYAnchor
            ),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            // Center Overlay
            //bracket ImageView
            bracketImageView.centerXAnchor.constraint(
                equalTo: view.centerXAnchor
            ),
            bracketImageView.centerYAnchor.constraint(
                equalTo: view.centerYAnchor,
                constant: -50
            ),
            bracketImageView.widthAnchor.constraint(equalToConstant: 250),
            bracketImageView.heightAnchor.constraint(equalToConstant: 250),
            //overlay ImageView
            overlayImageView.centerXAnchor.constraint(
                equalTo: bracketImageView.centerXAnchor
            ),
            overlayImageView.centerYAnchor.constraint(
                equalTo: bracketImageView.centerYAnchor
            ),
            overlayImageView.widthAnchor.constraint(equalToConstant: 80),
            overlayImageView.heightAnchor.constraint(equalToConstant: 80),

            // Bottom Bar
            //Bottom BarView
            bottomBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomBarView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor
            ),
            bottomBarView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bottomBarView.heightAnchor.constraint(equalToConstant: 150),
            //ShutterButton
            shutterButton.centerXAnchor.constraint(
                equalTo: bottomBarView.centerXAnchor
            ),
            shutterButton.centerYAnchor.constraint(
                equalTo: bottomBarView.centerYAnchor
            ),
            shutterButton.widthAnchor.constraint(equalToConstant: 70),
            shutterButton.heightAnchor.constraint(equalToConstant: 70),
        ])
    }
    //MARK: - CAMERA SETUP
    //Configure the camera session
    private func setupCamera() {
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo

        guard let backCamera = AVCaptureDevice.default(for: .video) else {
            print("Unable to access back camera! (Are you on Simulator?)")

            view.backgroundColor = .darkGray
            return
        }

        do {
            let input = try AVCaptureDeviceInput(device: backCamera)
            photoOutput = AVCapturePhotoOutput()

            if captureSession.canAddInput(input)
                && captureSession.canAddOutput(photoOutput)
            {
                captureSession.addInput(input)
                captureSession.addOutput(photoOutput)

                // Create the layer
                let layer = AVCaptureVideoPreviewLayer(session: captureSession)
                layer.videoGravity = .resizeAspectFill

                // Using the new API for setting rotation
                if let connection = layer.connection {
                    if connection.isVideoRotationAngleSupported(0) {
                        connection.videoRotationAngle = 0
                    }
                }

                // Assign to the property
                self.previewLayer = layer

                // Insert preview layer behind all UI elements
                view.layer.insertSublayer(layer, at: 0)
            }
        } catch let error {
            print(
                "Error unable to initialize back camera: \(error.localizedDescription)"
            )
        }
    }
    //MARK: - CAMERA CONTROLS
    //Begin to capture
    private func startCamera() {

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession.startRunning()
        }
    }

    private func stopCamera() {
        if captureSession.isRunning {
            captureSession.stopRunning()
        }
    }

    // MARK: - Actions

    @objc private func didTapClose() {
        dismiss(animated: true)
    }

    @objc private func didTapShutter() {

        guard let output = photoOutput else {
            print("Simulating capture on Simulator...")

            let renderer = UIGraphicsImageRenderer(size: view.bounds.size)
            let fakeImage = renderer.image { ctx in
                view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
            }
            delegate?.didCaptureDocument(fakeImage)
            dismiss(animated: true)
            return
        }

        let settings = AVCapturePhotoSettings()
        output.capturePhoto(with: settings, delegate: self)
    }
}

// MARK: - AVCapturePhotoCaptureDelegate

extension CustomDocumentScannerViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: Error?
    ) {
        guard let imageData = photo.fileDataRepresentation(),
            let image = UIImage(data: imageData)
        else {
            print("Error capturing photo: \(String(describing: error))")
            return
        }

        stopCamera()
        delegate?.didCaptureDocument(image)
        dismiss(animated: true)
    }
}
