import UIKit

class CircularProgressView: UIView {
    
    enum ProgressMode {
        case achievement    // Steps: Blue always
        case limitWarning   // Calories: Blue -> Yellow -> Red
    }
    
    // MARK: - Properties
    private var progressLayers: [CAShapeLayer] = []
    private var trackLayers: [CAShapeLayer] = []
    
    /// Array of progress values (0.0 to 1.0) - each value creates a concentric ring
    private var progressValues: [Float] = []
    
    /// Array of modes for each ring (defaults to .achievement if not specified)
    var modes: [ProgressMode] = []
    
    /// Default mode used when modes array doesn't have enough values
    var defaultMode: ProgressMode = .achievement
    
    /// Default colors for each ring (cycles through if more rings than colors)
    var ringColors: [UIColor] = [
        UIColor(red: 100/255, green: 180/255, blue: 255/255, alpha: 1),  // Blue
        UIColor(red: 255/255, green: 100/255, blue: 130/255, alpha: 1),  // Pink/Red
        UIColor(red: 100/255, green: 220/255, blue: 150/255, alpha: 1),  // Green
        UIColor(red: 255/255, green: 200/255, blue: 100/255, alpha: 1),  // Orange/Yellow
        UIColor(red: 180/255, green: 130/255, blue: 255/255, alpha: 1)   // Purple
    ]
    
    /// Thickness of each ring
    var lineWidth: CGFloat = 12 {
        didSet {
            updateLayerWidths()
            setNeedsLayout()
        }
    }
    
    /// Spacing between concentric rings
    var ringSpacing: CGFloat = 4 {
        didSet {
            setNeedsLayout()
        }
    }
    
    var trackColor: UIColor = UIColor(white: 0.2, alpha: 1) {
        didSet {
            trackLayers.forEach { $0.strokeColor = trackColor.cgColor }
        }
    }
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    // MARK: - Setup
    private func setupView() {
        self.addRoundedCorner()
    }
    
    private func createLayerPair() -> (track: CAShapeLayer, progress: CAShapeLayer) {
        let trackLayer = CAShapeLayer()
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.lineCap = .round
        trackLayer.strokeEnd = 1.0
        trackLayer.strokeColor = trackColor.cgColor
        trackLayer.lineWidth = lineWidth
        
        let progressLayer = CAShapeLayer()
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.lineCap = .round
        progressLayer.strokeEnd = 0.0
        progressLayer.lineWidth = lineWidth
        
        return (trackLayer, progressLayer)
    }
    
    private func updateLayerWidths() {
        trackLayers.forEach { $0.lineWidth = lineWidth }
        progressLayers.forEach { $0.lineWidth = lineWidth }
    }
    
    /// Sets up the required number of layer pairs based on the progress array count
    private func setupLayers(count: Int) {
        // Remove existing layers
        trackLayers.forEach { $0.removeFromSuperlayer() }
        progressLayers.forEach { $0.removeFromSuperlayer() }
        trackLayers.removeAll()
        progressLayers.removeAll()
        
        // Create new layers for each ring
        for _ in 0..<count {
            let pair = createLayerPair()
            layer.addSublayer(pair.track)
            layer.addSublayer(pair.progress)
            trackLayers.append(pair.track)
            progressLayers.append(pair.progress)
        }
    }
    
    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let maxRadius = (min(bounds.width, bounds.height) - lineWidth - 16) / 2
        
        // Calculate radius for each ring (outermost to innermost)
        for (index, (trackLayer, progressLayer)) in zip(trackLayers, progressLayers).enumerated() {
            let radiusOffset = CGFloat(index) * (lineWidth + ringSpacing)
            let radius = maxRadius - radiusOffset
            
            guard radius > 0 else { continue }
            
            let circularPath = UIBezierPath(
                arcCenter: center,
                radius: radius,
                startAngle: -CGFloat.pi / 2,
                endAngle: 2 * CGFloat.pi - CGFloat.pi / 2,
                clockwise: true
            )
            
            trackLayer.path = circularPath.cgPath
            trackLayer.lineWidth = lineWidth
            
            progressLayer.path = circularPath.cgPath
            progressLayer.lineWidth = lineWidth
        }
    }
    
    // MARK: - Public Methods
    
    /// Sets multiple progress values - creates concentric rings, one inside another
    /// - Parameters:
    ///   - values: Array of progress values (0.0 to 1.0). First value is outermost ring.
    ///   - animated: Whether to animate the progress change
    func setProgress(values: [Float], animated: Bool = true) {
        progressValues = values
        
        // Create layers if count changed
        if values.count != progressLayers.count {
            setupLayers(count: values.count)
            setNeedsLayout()
            layoutIfNeeded()
        }
        
        // Update each progress layer
        for (index, value) in values.enumerated() {
            let clampedValue = max(0, min(1, value))
            let mode = index < modes.count ? modes[index] : defaultMode
            let targetColor = getColor(for: clampedValue, mode: mode, ringIndex: index)
            
            let progressLayer = progressLayers[index]
            
            if animated {
                // Animate stroke
                let strokeAnimation = CABasicAnimation(keyPath: "strokeEnd")
                strokeAnimation.fromValue = progressLayer.strokeEnd
                strokeAnimation.toValue = clampedValue
                strokeAnimation.duration = 0.5
                strokeAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                
                // Animate color
                let colorAnimation = CABasicAnimation(keyPath: "strokeColor")
                colorAnimation.fromValue = progressLayer.strokeColor
                colorAnimation.toValue = targetColor.cgColor
                colorAnimation.duration = 0.5
                
                progressLayer.strokeEnd = CGFloat(clampedValue)
                progressLayer.strokeColor = targetColor.cgColor
                
                progressLayer.add(strokeAnimation, forKey: "animateProgress")
                progressLayer.add(colorAnimation, forKey: "animateColor")
            } else {
                progressLayer.strokeEnd = CGFloat(clampedValue)
                progressLayer.strokeColor = targetColor.cgColor
            }
        }
    }
    
    /// Sets a single progress value (backward compatible)
    /// - Parameters:
    ///   - value: Progress value (0.0 to 1.0)
    ///   - animated: Whether to animate the progress change
    func setProgress(to value: Float, animated: Bool = true) {
        setProgress(values: [value], animated: animated)
    }
    
    private func getColor(for value: Float, mode: ProgressMode, ringIndex: Int) -> UIColor {
        switch mode {
        case .achievement:
            // Return color based on ring index (cycles through available colors)
            return ringColors[ringIndex % ringColors.count]
            
        case .limitWarning:
            // Blue -> Yellow -> Red logic
            if value < 0.75 {
                return ringColors[ringIndex % ringColors.count] // Safe zone
            } else if value < 0.90 {
                return .systemYellow // Warning
            } else {
                return .systemRed // Danger
            }
        }
    }
    
    /// Convenience method to configure the view with multiple rings
    /// - Parameters:
    ///   - modes: Array of modes for each ring
    ///   - values: Array of progress values
    ///   - thickness: Line width for each ring
    ///   - spacing: Spacing between rings
    func configure(modes: [ProgressMode], values: [Float], thickness: CGFloat, spacing: CGFloat = 4) {
        self.modes = modes
        self.lineWidth = thickness
        self.ringSpacing = spacing
        self.setProgress(values: values)
    }
    
    /// Backward compatible convenience method for single ring
    func configure(mode: ProgressMode, progress: Float, thickness: CGFloat) {
        self.modes = [mode]
        self.lineWidth = thickness
        self.setProgress(to: progress)
    }
}
