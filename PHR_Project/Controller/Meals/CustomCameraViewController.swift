

import UIKit
import AVFoundation

// Protocol to handle the captured image and navigation
protocol CustomCameraDelegate: AnyObject {
    func didCaptureImage(_ image: UIImage)
    func didTapManuallyLog()
}

class CustomCameraViewController: UIViewController {

    
    // MARK: - ORIENTATION
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    // MARK: - PROPERTIES
    weak var delegate: CustomCameraDelegate?
    
    // Camera Session Properties
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer?
    var photoOutput: AVCapturePhotoOutput!

    // MARK: - UI COMPONENTS
    // Header Controls
    private let closeButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)
        button.setImage(UIImage(systemName: "xmark.circle.fill", withConfiguration: config), for: .normal)
        button.tintColor = .systemGray
        return button
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Scan Your Meal"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        return label
    }()
    
    // Scanning Overlay (Viewfinder)
    private let overlayImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "bowl.fill")
        imageView.tintColor = .black
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let bracketImageView: UIImageView = {
        let imageView = UIImageView()
        let config = UIImage.SymbolConfiguration(pointSize: 200, weight: .ultraLight)
        imageView.image = UIImage(systemName: "viewfinder", withConfiguration: config)
        imageView.tintColor = UIColor(red: 0.4, green: 0.7, blue: 1.0, alpha: 1.0)
        return imageView
    }()

    // Bottom Controls
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
    
    private let manuallyLogButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.baseForegroundColor = .white
        config.baseBackgroundColor = .systemGray.withAlphaComponent(0.5)
        config.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20)
        config.cornerStyle = .fixed               
        config.background.cornerRadius = 18
        
        // One-liner for Font
        config.attributedTitle = AttributedString("Manually Log", attributes: AttributeContainer([
            .font: UIFont.systemFont(ofSize: 16, weight: .medium)
        ]))
        
        return UIButton(configuration: config)
    }()

    // MARK: - LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        setupUI()
        setupCamera()
        startCamera()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Ensure the layer fills the screen
        previewLayer?.frame = view.layer.bounds
        
        // Orientation restrictions
        if let connection = previewLayer?.connection {
            if #available(iOS 17.0, *) {
                // Prefer the modern rotation angle API on iOS 17+
                if connection.isVideoRotationAngleSupported(90) {
                    connection.videoRotationAngle = 90
                }
            } else {
                // Fallback for iOS < 17 using deprecated orientation API
                if connection.isVideoOrientationSupported {
                    connection.videoOrientation = .portrait
                }
            }
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    // MARK: - SETUP FUNCTIONS
    // Main UI construction
    private func setupUI() {
        addSubviews()
        setupConstraints()
        setupTargets()
    }

    // Add elements to view hierarchy
    private func addSubviews() {
        [closeButton, titleLabel, bracketImageView, overlayImageView, bottomBarView].forEach { view.addSubview($0) }
        [shutterButton, manuallyLogButton].forEach { bottomBarView.addSubview($0) }
        
        // Prepare for Auto Layout
        view.subviews.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        bottomBarView.subviews.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
    }

    // Camera Layout configuration
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Top Bar Controls
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            titleLabel.centerYAnchor.constraint(equalTo: closeButton.centerYAnchor),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // Viewfinder (Center)
            bracketImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            bracketImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
            bracketImageView.widthAnchor.constraint(equalToConstant: 250),
            bracketImageView.heightAnchor.constraint(equalToConstant: 250),
            
            overlayImageView.centerXAnchor.constraint(equalTo: bracketImageView.centerXAnchor),
            overlayImageView.centerYAnchor.constraint(equalTo: bracketImageView.centerYAnchor),
            overlayImageView.widthAnchor.constraint(equalToConstant: 80),
            overlayImageView.heightAnchor.constraint(equalToConstant: 80),

            // Bottom Bar Area
            bottomBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomBarView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bottomBarView.heightAnchor.constraint(equalToConstant: 200),
            
            shutterButton.centerXAnchor.constraint(equalTo: bottomBarView.centerXAnchor),
            shutterButton.centerYAnchor.constraint(equalTo: bottomBarView.centerYAnchor, constant: -20),
            shutterButton.widthAnchor.constraint(equalToConstant: 70),
            shutterButton.heightAnchor.constraint(equalToConstant: 70),
            
            manuallyLogButton.topAnchor.constraint(equalTo: shutterButton.bottomAnchor, constant: 20),
            manuallyLogButton.centerXAnchor.constraint(equalTo: bottomBarView.centerXAnchor)
        ])
    }

    // Attach actions to buttons
    private func setupTargets() {
        closeButton.addTarget(self, action: #selector(didTapClose), for: .touchUpInside)
        shutterButton.addTarget(self, action: #selector(didTapShutter), for: .touchUpInside)
        manuallyLogButton.addTarget(self, action: #selector(didTapManuallyLog), for: .touchUpInside)
    }
    
    // MARK: - CAMERA LOGIC
    // Configure AVCaptureSession for photo capture
    private func setupCamera() {
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo
        
        guard let backCamera = AVCaptureDevice.default(for: .video) else {
            handleMissingCamera()
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: backCamera)
            photoOutput = AVCapturePhotoOutput()
            
            if captureSession.canAddInput(input) && captureSession.canAddOutput(photoOutput) {
                captureSession.addInput(input)
                captureSession.addOutput(photoOutput)
                setupPreviewLayer()
            }
        } catch {
            print("Camera initialization failed: \(error.localizedDescription)")
        }
    }

    // Initialize the visual preview layer

    private func setupPreviewLayer() {
        let layer = AVCaptureVideoPreviewLayer(session: captureSession)
        layer.videoGravity = .resizeAspectFill
        
        self.previewLayer = layer
        view.layer.insertSublayer(layer, at: 0)
    }

    // Begin capturing frames (Background thread)
    private func startCamera() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession.startRunning()
        }
    }
    
    // End camera stream
    private func stopCamera() {
         if captureSession.isRunning {
             captureSession.stopRunning()
         }
     }

    // Fallback UI for Simulator
    private func handleMissingCamera() {
        print("Camera inaccessible. Using Simulator fallback.")
        view.backgroundColor = .darkGray
    }

    // MARK: - ACTIONS
    @objc private func didTapClose() {
        dismiss(animated: true)
    }

    @objc private func didTapShutter() {
        guard let output = photoOutput else {
            simulateCapture() // Handle Simulator logic
            return
        }

        let settings = AVCapturePhotoSettings()
        output.capturePhoto(with: settings, delegate: self)
    }
    
    @objc private func didTapManuallyLog() {
        delegate?.didTapManuallyLog()
    }

    // Fake capture logic for testing on Simulator
    private func simulateCapture() {
        let renderer = UIGraphicsImageRenderer(size: view.bounds.size)
        let fakeImage = renderer.image { _ in
            view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        }
        delegate?.didCaptureImage(fakeImage)
        dismiss(animated: true)
    }
}

// MARK: - PHOTO OUTPUT DELEGATE
extension CustomCameraViewController: AVCapturePhotoCaptureDelegate {
    
    // Process the raw photo data into a UIImage
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else {
            print("Capture Error: \(error?.localizedDescription ?? "Unknown error")")
            return
        }
        
        stopCamera()
        delegate?.didCaptureImage(image)
        dismiss(animated: true)
    }
}

