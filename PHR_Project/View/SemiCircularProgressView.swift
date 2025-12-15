import UIKit

class SemicircularProgressView: UIView {
    
    // MARK: - Properties
    private var progressLayer = CAShapeLayer()
    private var trackLayer = CAShapeLayer()
    
    var lineWidth: CGFloat = 20 {
        didSet {
            trackLayer.lineWidth = lineWidth
            progressLayer.lineWidth = lineWidth
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
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.lineCap = .round
        trackLayer.strokeEnd = 1.0
        layer.addSublayer(trackLayer)
        
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.lineCap = .round
        progressLayer.strokeEnd = 0.0
        layer.addSublayer(progressLayer)
        
        trackLayer.lineWidth = lineWidth
        progressLayer.lineWidth = lineWidth
    }
    
    // MARK: - Layout (FIXED FOR TOP ALIGNMENT)
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // 1. Calculate Radius based on width
        let radius = (bounds.width - lineWidth - 8) / 2
        
        // 2. Center Point Calculation
        // X: Middle of the view
        // Y: We start at the top (0) + half the line thickness + radius.
        //    This effectively "pushes" the center down just enough so the arch touches the top edge.
        let center = CGPoint(x: bounds.midX, y: (lineWidth / 2) + radius + 6)
        
        // 3. Define the path (Rainbow shape)
        // Start at PI (9 o'clock) -> End at 2*PI (3 o'clock) -> Clockwise
        let circularPath = UIBezierPath(arcCenter: center,
                                        radius: radius,
                                        startAngle: CGFloat.pi,
                                        endAngle: 2 * CGFloat.pi,
                                        clockwise: true)
        
        trackLayer.path = circularPath.cgPath
        trackLayer.strokeColor = trackColor.cgColor
        trackLayer.lineWidth = lineWidth
        
        progressLayer.path = circularPath.cgPath
        progressLayer.strokeColor = progressColor.cgColor
        progressLayer.lineWidth = lineWidth
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
    
    func configure(progress: Float, thickness: CGFloat, color: UIColor? = nil) {
        self.lineWidth = thickness
        if let color = color {
            self.progressColor = color
        }
        self.setProgress(to: progress)
    }
}
