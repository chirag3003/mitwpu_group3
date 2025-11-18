//
//  HealthMetric.swift
//  PHR_Project
//
//  Created by SDC_USER on 17/11/25.
//

import Foundation

// MARK: - Base Health Metric Protocol
protocol HealthMetric {
    var title: String { get }
    var icon: String { get }
}

// MARK: - Glucose Model
struct GlucoseMetric: HealthMetric {
    let title: String = "Glucose"
    let icon: String = "heart.fill"
    let value: Int
    let unit: String = "mg/dL"
    
    init(value: Int) {
        self.value = value
    }
}

// MARK: - Water Intake Model
struct WaterIntakeMetric: HealthMetric {
    let title: String = "Water Intake"
    let icon: String = "drop.fill"
    let current: Int
    let goal: Int
    let unit: String = "glasses"
    
    init(current: Int, goal: Int) {
        self.current = current
        self.goal = goal
    }
}

// MARK: - Steps Model
struct StepsMetric: HealthMetric {
    let title: String = "Steps"
    let icon: String = "figure.walk"
    let steps: Int
    let caloriesBurned: Int
    let calorieGoal: Int
    
    init(steps: Int, caloriesBurned: Int, calorieGoal: Int) {
        self.steps = steps
        self.caloriesBurned = caloriesBurned
        self.calorieGoal = calorieGoal
    }
    
    var progress: Float {
        return Float(caloriesBurned) / Float(calorieGoal)
    }
}

// MARK: - Calories Model
struct CaloriesMetric: HealthMetric {
    let title: String = "Calories"
    let icon: String = "flame.fill"
    let consumed: Int
    let goal: Int
    
    init(consumed: Int, goal: Int) {
        self.consumed = consumed
        self.goal = goal
    }
    
    var progress: Float {
        return Float(consumed) / Float(goal)
    }
}
