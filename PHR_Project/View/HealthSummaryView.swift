//
//  HealthSummaryView.swift
//  PHR_Project
//
//  Created by SDC_USER on 17/11/25.
//

import UIKit

class HealthSummaryView: UIView {
    
    // MARK: - UI Components
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Summary"
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let topRowStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 16
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let bottomRowStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 16
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let glucoseCard = CompactMetricCardView()
    private let waterCard = CompactMetricCardView()
    private let stepsCard = CircularProgressCardView()
    private let caloriesCard = CircularProgressCardView()
    
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
        
        addSubview(titleLabel)
        addSubview(topRowStack)
        addSubview(bottomRowStack)
        
        // Add cards to stacks
        topRowStack.addArrangedSubview(glucoseCard)
        topRowStack.addArrangedSubview(waterCard)
        
        bottomRowStack.addArrangedSubview(stepsCard)
        bottomRowStack.addArrangedSubview(caloriesCard)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Title
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            // Top Row
            topRowStack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            topRowStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            topRowStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            topRowStack.heightAnchor.constraint(equalToConstant: 160),
            
            // Bottom Row
            bottomRowStack.topAnchor.constraint(equalTo: topRowStack.bottomAnchor, constant: 16),
            bottomRowStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            bottomRowStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            bottomRowStack.heightAnchor.constraint(equalToConstant: 220),
            bottomRowStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
    }
    
    // MARK: - Configuration
    func configure(glucose: GlucoseMetric, water: WaterIntakeMetric, steps: StepsMetric, calories: CaloriesMetric) {
        // Configure glucose card
        glucoseCard.configure(
            icon: glucose.icon,
            title: glucose.title,
            value: "\(glucose.value)",
            unit: glucose.unit
        )
        
        // Configure water card
        waterCard.configure(
            icon: water.icon,
            title: water.title,
            value: "\(water.current)",
            unit: "/\(water.goal) \(water.unit)"
        )
        
        // Configure steps card
        stepsCard.configure(
            icon: steps.icon,
            title: steps.title,
            mainValue: "\(steps.steps)",
            subValue: "\(steps.caloriesBurned)/\(steps.calorieGoal) Kcal",
            progress: steps.progress
        )
        
        // Configure calories card
        caloriesCard.configure(
            icon: calories.icon,
            title: calories.title,
            mainValue: "\(calories.consumed)",
            subValue: "out of \(calories.goal)",
            progress: calories.progress
        )
    }
}
