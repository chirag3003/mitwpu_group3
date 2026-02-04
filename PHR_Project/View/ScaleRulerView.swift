//
//  ScaleRulerView.swift
//  PHR_Project
//
//  Created by Sushant Pulipati on 02/02/26.
//

import Foundation
import UIKit

class ScaleRulerView: UIView {
    
    // MARK: - Public Properties
    var minValue: Double = 140 {
        didSet { rebuildScale() }
    }
    
    var maxValue: Double = 220 {
        didSet { rebuildScale() }
    }
    
    var currentValue: Double = 176 {
        didSet {
            updateValueLabel()
            valueChangedHandler?(currentValue)
        }
    }
    
    var pixelsPerUnit: CGFloat = 10 {
        didSet { rebuildScale() }
    }
    
    var majorTickColor: UIColor = UIColor.lightGray.withAlphaComponent(0.7) {
        didSet { rebuildScale() }
    }
    
    var mediumTickColor: UIColor = UIColor.lightGray.withAlphaComponent(0.5) {
        didSet { rebuildScale() }
    }
    
    var minorTickColor: UIColor = UIColor.lightGray.withAlphaComponent(0.3) {
        didSet { rebuildScale() }
    }
    
    var indicatorColor: UIColor = .white {
        didSet { centerIndicator.backgroundColor = indicatorColor }
    }
    
    var labelTextColor: UIColor = UIColor.lightGray.withAlphaComponent(0.8) {
        didSet { rebuildScale() }
    }
    
    // Closure for value changes
    var valueChangedHandler: ((Double) -> Void)?
    
    // MARK: - Private Properties
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsHorizontalScrollIndicator = false
        sv.showsVerticalScrollIndicator = false
        sv.bounces = true
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let centerIndicator: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.layer.shadowColor = UIColor.white.cgColor
        view.layer.shadowRadius = 8
        view.layer.shadowOpacity = 0.6
        view.layer.shadowOffset = .zero
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var isInitialScroll = true
    private var contentWidthConstraint: NSLayoutConstraint?
    private var hasScrolledToInitialValue = false
    
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
        backgroundColor = .clear
        
        // Add subviews
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        addSubview(centerIndicator)
        
        scrollView.delegate = self
        
        // Setup constraints
        NSLayoutConstraint.activate([
            // ScrollView fills the entire view
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            // ContentView
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.heightAnchor.constraint(equalTo: scrollView.heightAnchor),
            
            // Center indicator
            centerIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            centerIndicator.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -10),
            centerIndicator.widthAnchor.constraint(equalToConstant: 3),
            centerIndicator.heightAnchor.constraint(equalToConstant: 70)
        ])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Build scale when layout is ready
        if contentView.subviews.isEmpty && bounds.width > 0 {
            buildScale()
        }
        
        // Scroll to initial value after first layout
        if !hasScrolledToInitialValue && bounds.width > 0 && contentView.subviews.count > 0 {
            // Force layout to complete
            contentView.layoutIfNeeded()
            scrollView.layoutIfNeeded()
            
            // Now scroll to initial value
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.scrollToValue(self.currentValue, animated: false)
                self.hasScrolledToInitialValue = true
                print("✅ Scrolled to initial value: \(self.currentValue)")
            }
        }
    }
    
    // MARK: - Scale Building
    private func buildScale() {
        // Clear existing ticks
        contentView.subviews.forEach { $0.removeFromSuperview() }
        
        let range = Int(maxValue - minValue)
        let totalWidth = CGFloat(range) * pixelsPerUnit
        
        // Set content width with padding
        let contentWidth = totalWidth + bounds.width
        
        // Remove old constraint if exists
        if let oldConstraint = contentWidthConstraint {
            contentView.removeConstraint(oldConstraint)
        }
        
        contentWidthConstraint = contentView.widthAnchor.constraint(equalToConstant: contentWidth)
        contentWidthConstraint?.isActive = true
        
        // Starting position (centered)
        var xPosition: CGFloat = bounds.width / 2
        
        // Draw tick marks for each unit
        for i in Int(minValue)...Int(maxValue) {
            drawTick(at: xPosition, value: i)
            xPosition += pixelsPerUnit
        }
        
        //print("🔨 Built scale: min=\(minValue), max=\(maxValue), contentWidth=\(contentWidth)")
    }
    
    private func drawTick(at xPosition: CGFloat, value: Int) {
        let isMajor = value % 10 == 0  // Every 10th tick
        let isMedium = value % 5 == 0   // Every 5th tick
        
        // Tick dimensions
        let tickHeight: CGFloat = isMajor ? 35 : (isMedium ? 25 : 18)
        let tickWidth: CGFloat = 2
        let tickColor = isMajor ? majorTickColor : (isMedium ? mediumTickColor : minorTickColor)
        
        // Create tick view
        let tick = UIView()
        tick.backgroundColor = tickColor
        tick.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(tick)
        
        NSLayoutConstraint.activate([
            tick.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: xPosition - tickWidth/2),
            tick.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: -10),
            tick.widthAnchor.constraint(equalToConstant: tickWidth),
            tick.heightAnchor.constraint(equalToConstant: tickHeight)
        ])
        
        // Add number label for major ticks
        if isMajor {
            let label = UILabel()
            label.text = "\(value)"
            label.textColor = labelTextColor
            label.font = .systemFont(ofSize: 16, weight: .regular)
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(label)
            
            NSLayoutConstraint.activate([
                label.centerXAnchor.constraint(equalTo: tick.centerXAnchor),
                label.topAnchor.constraint(equalTo: tick.bottomAnchor, constant: 8),
                label.widthAnchor.constraint(equalToConstant: 50)
            ])
        }
    }
    
    private func rebuildScale() {
        guard bounds.width > 0 else { return }
        hasScrolledToInitialValue = false
        buildScale()
        setNeedsLayout()
    }
    
    // MARK: - Public Methods
    
    /// Set the value programmatically
    /// - Parameters:
    ///   - value: The value to set
    ///   - animated: Whether to animate the scroll
    func setValue(_ value: Double, animated: Bool = false) {
        currentValue = max(minValue, min(maxValue, value))
        scrollToValue(currentValue, animated: animated)
    }
    
    /// Get the current value
    func getValue() -> Double {
        return currentValue
    }
    
    /// Configure the scale with all parameters
    /// - Parameters:
    ///   - min: Minimum value
    ///   - max: Maximum value
    ///   - initial: Initial value
    ///   - spacing: Pixels per unit
    func configure(min: Double, max: Double, initial: Double, spacing: CGFloat = 10) {
        self.minValue = min
        self.maxValue = max
        self.currentValue = initial
        self.pixelsPerUnit = spacing
        self.hasScrolledToInitialValue = false
        rebuildScale()
    }
    
    // MARK: - Private Methods
    private func scrollToValue(_ value: Double, animated: Bool) {
        let offset = CGFloat(value - minValue) * pixelsPerUnit
        scrollView.setContentOffset(CGPoint(x: offset, y: 0), animated: animated)
        //print("📍 Scrolling to value: \(value), offset: \(offset)")
    }
    
    private func calculateValueFromOffset(_ offset: CGFloat) -> Double {
        let value = minValue + Double(offset / pixelsPerUnit)
        return max(minValue, min(maxValue, value))
    }
    
    private func updateValueLabel() {
        // Trigger the closure to update external label
        // This is handled by the closure itself
    }
}

// MARK: - UIScrollViewDelegate
extension ScaleRulerView: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.x
        let value = calculateValueFromOffset(offset)
        let roundedValue = round(value)
        
        if roundedValue != currentValue && !isInitialScroll {
            currentValue = roundedValue
            
            // Light haptic feedback
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred(intensity: 0.5)
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        isInitialScroll = false
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        // Snap to nearest whole value
        let targetOffset = targetContentOffset.pointee.x
        let targetValue = calculateValueFromOffset(targetOffset)
        let roundedValue = round(targetValue)
        let snappedOffset = CGFloat(roundedValue - minValue) * pixelsPerUnit
        
        targetContentOffset.pointee.x = snappedOffset
        
        // Medium haptic feedback on snap
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        // Ensure we're exactly on a value
        let offset = scrollView.contentOffset.x
        let value = calculateValueFromOffset(offset)
        let roundedValue = round(value)
        currentValue = roundedValue
        scrollToValue(roundedValue, animated: true)
    }
}
