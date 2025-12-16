import UIKit

class CircularProgressView: UIView {
    
    enum ProgressMode {
            case achievement    // Steps: Blue always
            case limitWarning   // Calories: Blue -> Yellow -> Red
        }
    
    // MARK: - Properties
    private var progressLayer = CAShapeLayer()
    private var trackLayer = CAShapeLayer()
    
    var mode: ProgressMode = .achievement
    
    private let defaultColor = UIColor(red: 100/255, green: 180/255, blue: 255/255, alpha: 1)
    
    // 1. ADD THIS: A property to control thickness
    var lineWidth: CGFloat = 20 {
        didSet {
            trackLayer.lineWidth = lineWidth
            progressLayer.lineWidth = lineWidth
            // We must trigger layout again because the radius calculation depends on line width
            setNeedsLayout()
        }
    }
    
//    var progressColor: UIColor = UIColor(red: 100/255, green: 180/255, blue: 255/255, alpha: 1) {
//        didSet { progressLayer.strokeColor = progressColor.cgColor }
//    }
    
    var trackColor: UIColor = UIColor(white: 0.2, alpha: 1) {
        didSet { trackLayer.strokeColor = trackColor.cgColor }
    }
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayers()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayers()
    }
    
    // MARK: - Setup
    private func setupLayers() {
        // Track Layer
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.lineCap = .round
        trackLayer.strokeEnd = 1.0
        trackLayer.strokeColor = trackColor.cgColor
        layer.addSublayer(trackLayer)
        
        // Progress Layer
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.lineCap = .round
        progressLayer.strokeEnd = 0.0
        progressLayer.strokeColor = defaultColor.cgColor
        layer.addSublayer(progressLayer)
        
        // Initial set of line width
        trackLayer.lineWidth = lineWidth
        progressLayer.lineWidth = lineWidth
        
        self.addRoundedCorner()
    }
    
    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        // 2. UPDATE THIS: Calculate radius based on the current lineWidth
        // We subtract lineWidth so the stroke stays inside the view bounds
        let radius = (min(bounds.width, bounds.height) - lineWidth - 16) / 2
        
        let circularPath = UIBezierPath(arcCenter: center,
                                        radius: radius,
                                        startAngle: -CGFloat.pi / 2,
                                        endAngle: 2 * CGFloat.pi - CGFloat.pi / 2,
                                        clockwise: true)
        
        trackLayer.path = circularPath.cgPath
        trackLayer.lineWidth = lineWidth // Ensure width is set during layout
        
        progressLayer.path = circularPath.cgPath
        progressLayer.lineWidth = lineWidth // Ensure width is set during layout
    }
    
    // MARK: - Public Methods
    func setProgress(to value: Float, animated: Bool = true) {
        let clampedValue = max(0, min(1, value))
        
        let targetColor = getColor(for: clampedValue)
        
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
    
    private func getColor(for value: Float) -> UIColor {
            switch mode {
            case .achievement:
                // Always return the default blue
                return defaultColor
                
            case .limitWarning:
                // Blue -> Yellow -> Red logic
                if value < 0.75 {
                    return defaultColor // Safe zone (Blue)
                } else if value < 0.90 {
                    return .systemYellow // Warning
                } else {
                    return .systemRed // Danger
                }
            }
        }
    
    // 3. ADD THIS: A convenience method to set everything at once
    func configure(mode: ProgressMode, progress: Float, thickness: CGFloat) {
            self.mode = mode
            self.lineWidth = thickness
            self.setProgress(to: progress)
        }
}
