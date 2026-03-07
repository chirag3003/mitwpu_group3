//
//  Constants.swift
//  PHR_Project
//
//  Created on 12/12/25.
//

import UIKit

// MARK: - UI Constants

enum UIConstants {
    
    enum CornerRadius {
        static let small: CGFloat = 10
        static let medium: CGFloat = 16
        static let large: CGFloat = 20
        static let huge: CGFloat = 30
    }
    
    enum Spacing {
        static let extraSmall: CGFloat = 4
        static let small: CGFloat = 8
        static let medium: CGFloat = 16
        static let large: CGFloat = 24
    }
    
    enum Padding {
        static let medium: CGFloat = 10
    }
    
    enum Shadow {
        static let defaultOpacity: Float = 0.08
        static let mediumOpacity: Float = 0.15
        static let defaultRadius: CGFloat = 6
        static let defaultOffset = CGSize(width: 0, height: 2)
        static let mediumOffset = CGSize(width: 0, height: 3)
    }
    
    enum ProgressThickness {
        static let thin: CGFloat = 12
        static let thick: CGFloat = 25
    }
    
    enum CollectionLayout {
        static let oneThirdWidth: CGFloat = 1.0 / 3.0
        static let fullWidth: CGFloat = 1.0
        
        static let memberItemHeight: CGFloat = 150
        static let headerHeight: CGFloat = 220
    }
    
    enum AnimationDuration {
        static let medium: TimeInterval = 0.5
    }
}

// MARK: - Notification Names

enum NotificationNames {
    static let profileUpdated = "ProfileUpdated"
    static let symptomsUpdated = "SymptomsUpdated"
    static let waterIntakeUpdated = "waterIntakeUpdated"
    static let mealsUpdated = "MealsUpdated"
    static let glucoseUpdated = "GlucoseReadingsUpdated"
    static let documentsUpdated = "DocumentsUpdated"
    static let doctorsUpdated = "DoctorsUpdated"
    static let familiesUpdated = "FamiliesUpdated"
    static let familyMembersUpdated = "FamilyMembersUpdated"
    static let familyPermissionsUpdated = "FamilyPermissionsUpdated"
    static let familySelectionUpdated = "FamilySelectionUpdated"
    static let sharedAllergiesUpdated = "SharedAllergiesUpdated"
}

// MARK: - Cell Identifiers

enum CellIdentifiers {
    static let allergyCell = "allergy_cell"
    static let symptomCell = "symptom_cell"
    static let browseCell = "browse_cell"
    static let mealCell = "MealCell"
    static let dateCell = "date_cell"
    static let doctorCell = "DoctorCell"
    static let reportCell = "ReportCell"
    static let sectionHeader = "SectionHeader"
}

// MARK: - Segue Identifiers

enum SegueIdentifiers {
    static let goToMemberDetails = "goToMemberDetails"
}

// MARK: - Default Values

enum DefaultValues {
    static let defaultTableRowHeight: CGFloat = 65.0
}

// MARK: - Health Goals

enum HealthGoals {
    static let dailyCalories = 2000
    static let dailySteps = 10000
    static let progressThickness: CGFloat = 16
    static let dailyCarbs = 220
    static let dailyProtein = 90
    static let dailyFiber = 35
}
