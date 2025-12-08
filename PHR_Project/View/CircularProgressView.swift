import UIKit

class CircularProgressView: UIView {
    
    // MARK: - Properties
    private var progressLayer = CAShapeLayer()
    private var trackLayer = CAShapeLayer()
    
    // Colors based on your screenshot
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
        // 1. Setup the Track Layer (Background)
        trackLayer.lineWidth = 20
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.lineCap = .round // Makes the ends rounded
        trackLayer.strokeEnd = 1.0
        layer.addSublayer(trackLayer)
        
        // 2. Setup the Progress Layer (Foreground)
        progressLayer.lineWidth = 20
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.lineCap = .round // Makes the ends rounded
        progressLayer.strokeEnd = 0.0 // Starts empty
        layer.addSublayer(progressLayer)
        
        // 3. Set border radius
        self.addRoundedCorner()
    }
    
    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Create the circular path
        // We start at -CGFloat.pi / 2 (which is 12 o'clock position)
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius = (min(bounds.width, bounds.height) - trackLayer.lineWidth - 16) / 2
        
        let circularPath = UIBezierPath(arcCenter: center,
                                        radius: radius,
                                        startAngle: -CGFloat.pi / 2,
                                        endAngle: 2 * CGFloat.pi - CGFloat.pi / 2,
                                        clockwise: true)
        
        trackLayer.path = circularPath.cgPath
        trackLayer.strokeColor = trackColor.cgColor
        
        progressLayer.path = circularPath.cgPath
        progressLayer.strokeColor = progressColor.cgColor
    }
    
    // MARK: - Public Methods
    func setProgress(to value: Float, animated: Bool = true) {
        let clampedValue = max(0, min(1, value)) // Ensure 0.0 to 1.0
        
        if animated {
            let animation = CABasicAnimation(keyPath: "strokeEnd")
            animation.fromValue = progressLayer.strokeEnd
            animation.toValue = clampedValue
            animation.duration = 0.5
            animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            progressLayer.strokeEnd = CGFloat(clampedValue)
            progressLayer.add(animation, forKey: "animateProgress")
        } else {
            progressLayer.strokeEnd = CGFloat(clampedValue)
        }
    }
}
