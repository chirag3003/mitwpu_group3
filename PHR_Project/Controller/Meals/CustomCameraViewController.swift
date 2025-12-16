
//
//  CustomCameraViewController.swift
//  PHR_Project
//
//  Created by Sushant Pulipati on 12/12/25.
//

// CustomCameraViewController.swift

import UIKit
import AVFoundation

// Protocol to handle the captured image
protocol CustomCameraDelegate: AnyObject {
    func didCaptureImage(_ image: UIImage)
    func didTapManuallyLog()
}

class CustomCameraViewController: UIViewController {

    
    weak var delegate: CustomCameraDelegate?

   
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer?
    var photoOutput: AVCapturePhotoOutput!

   
    
    // 1. Top Bar
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
    
    // 2. Center Overlay
    private let overlayImageView: UIImageView = {
        // This is the salad icon
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "bowl.fill")
        imageView.tintColor = .black
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let bracketImageView: UIImageView = {
        // This is the blue corner bracket image
        let imageView = UIImageView()
        
        let config = UIImage.SymbolConfiguration(pointSize: 200, weight: .ultraLight)
        imageView.image = UIImage(systemName: "viewfinder", withConfiguration: config)
        imageView.tintColor = UIColor(red: 0.4, green: 0.7, blue: 1.0, alpha: 1.0) // Light blue
        return imageView
    }()

    // 3. Bottom Bar
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
        let button = UIButton(type: .system)
        button.setTitle("Manually Log", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.systemGray.withAlphaComponent(0.5)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.layer.cornerRadius = 18
        button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        return button
    }()

    // --- Lifecycle ---

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

    // --- Setup Functions ---

    private func setupUI() {
        // Add subviews
        view.addSubview(closeButton)
        view.addSubview(titleLabel)
        view.addSubview(bracketImageView)
        view.addSubview(overlayImageView)
        view.addSubview(bottomBarView)
        bottomBarView.addSubview(shutterButton)
        bottomBarView.addSubview(manuallyLogButton)
        
        // Add targets
        closeButton.addTarget(self, action: #selector(didTapClose), for: .touchUpInside)
        shutterButton.addTarget(self, action: #selector(didTapShutter), for: .touchUpInside)
        manuallyLogButton.addTarget(self, action: #selector(didTapManuallyLog), for: .touchUpInside)

        // Disable Auto Layout masks
        [closeButton, titleLabel, bracketImageView, overlayImageView, bottomBarView, shutterButton, manuallyLogButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        // Constraints
        NSLayoutConstraint.activate([
            // Top Bar
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            titleLabel.centerYAnchor.constraint(equalTo: closeButton.centerYAnchor),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // Center Overlay
            bracketImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            bracketImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50), // Shift up slightly
            bracketImageView.widthAnchor.constraint(equalToConstant: 250),
            bracketImageView.heightAnchor.constraint(equalToConstant: 250),
            
            overlayImageView.centerXAnchor.constraint(equalTo: bracketImageView.centerXAnchor),
            overlayImageView.centerYAnchor.constraint(equalTo: bracketImageView.centerYAnchor),
            overlayImageView.widthAnchor.constraint(equalToConstant: 80),
            overlayImageView.heightAnchor.constraint(equalToConstant: 80),

            // Bottom Bar
            bottomBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomBarView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bottomBarView.heightAnchor.constraint(equalToConstant: 150),
            
            shutterButton.centerXAnchor.constraint(equalTo: bottomBarView.centerXAnchor),
            shutterButton.centerYAnchor.constraint(equalTo: bottomBarView.centerYAnchor),
            shutterButton.widthAnchor.constraint(equalToConstant: 70),
            shutterButton.heightAnchor.constraint(equalToConstant: 70),
            
            manuallyLogButton.centerYAnchor.constraint(equalTo: shutterButton.centerYAnchor),
            manuallyLogButton.leadingAnchor.constraint(equalTo: shutterButton.trailingAnchor, constant: 30)
        ])
    }
    
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
                    
                    if captureSession.canAddInput(input) && captureSession.canAddOutput(photoOutput) {
                        captureSession.addInput(input)
                        captureSession.addOutput(photoOutput)
                        
                        // Create the layer
                        let layer = AVCaptureVideoPreviewLayer(session: captureSession)
                        layer.videoGravity = .resizeAspectFill
                        layer.connection?.videoOrientation = .portrait
                        
                        // Assign to our property
                        self.previewLayer = layer
                        
                        // Insert preview layer behind all UI elements
                        view.layer.insertSublayer(layer, at: 0)
                    }
                } catch let error {
                    print("Error unable to initialize back camera:  \(error.localizedDescription)")
                }
    }
    
    private func startCamera() {
        // Start on a background thread to avoid blocking UI
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession.startRunning()
        }
    }
    
    private func stopCamera() {
         if captureSession.isRunning {
             captureSession.stopRunning()
         }
     }

    // --- Actions ---

    @objc private func didTapClose() {
        dismiss(animated: true)
    }

    @objc private func didTapShutter() {
        // If camera isn't running (Simulator), just simulate a fake capture
                guard let output = photoOutput else {
                    print("Simulating capture on Simulator...")
                    // Create a fake image (e.g. screenshot of the view)
                    let renderer = UIGraphicsImageRenderer(size: view.bounds.size)
                    let fakeImage = renderer.image { ctx in
                        view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
                    }
                    delegate?.didCaptureImage(fakeImage)
                    dismiss(animated: true)
                    return
                }

                let settings = AVCapturePhotoSettings()
                output.capturePhoto(with: settings, delegate: self)
    }
    
    @objc private func didTapManuallyLog() {
        delegate?.didTapManuallyLog()
        //dismiss(animated: true)
    }
}

// --- AVCapturePhotoCaptureDelegate ---

extension CustomCameraViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else {
            print("Error capturing photo: \(String(describing: error))")
            return
        }
        
        stopCamera()
        delegate?.didCaptureImage(image)
        dismiss(animated: true)
    }
}
