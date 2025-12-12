import UIKit

class CircularProgressView: UIView {
    
    // MARK: - Properties
    private var progressLayer = CAShapeLayer()
    private var trackLayer = CAShapeLayer()
    
    // 1. ADD THIS: A property to control thickness
    var lineWidth: CGFloat = 20 {
        didSet {
            trackLayer.lineWidth = lineWidth
            progressLayer.lineWidth = lineWidth
            // We must trigger layout again because the radius calculation depends on line width
            setNeedsLayout()
        }
    }
    
    var progressColor: UIColor = UIColor(red: 100/255, green: 180/255, blue: 255/255, alpha: 1) {
        didSet { progressLayer.strokeColor = progressColor.cgColor }
    }
    
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
        layer.addSublayer(trackLayer)
        
        // Progress Layer
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.lineCap = .round
        progressLayer.strokeEnd = 0.0
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
        trackLayer.strokeColor = trackColor.cgColor
        trackLayer.lineWidth = lineWidth // Ensure width is set during layout
        
        progressLayer.path = circularPath.cgPath
        progressLayer.strokeColor = progressColor.cgColor
        progressLayer.lineWidth = lineWidth // Ensure width is set during layout
    }
    
    // MARK: - Public Methods
    func setProgress(to value: Float, animated: Bool = true) {
        let clampedValue = max(0, min(1, value))
        
        if animated {
            let animation = CABasicAnimation(keyPath: "strokeEnd")
            animation.fromValue = progressLayer.strokeEnd
            animation.toValue = clampedValue
            animation.duration = UIConstants.AnimationDuration.medium
            animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            progressLayer.strokeEnd = CGFloat(clampedValue)
            progressLayer.add(animation, forKey: "animateProgress")
        } else {
            progressLayer.strokeEnd = CGFloat(clampedValue)
        }
    }
    
    // 3. ADD THIS: A convenience method to set everything at once
    func configure(progress: Float, thickness: CGFloat, color: UIColor? = nil) {
        self.lineWidth = thickness
        if let color = color {
            self.progressColor = color
        }
        self.setProgress(to: progress)
    }
}
