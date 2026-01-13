//
//  CoreDataManager.swift
//  PHR_Project
//
//  Created by SDC_USER on 13/01/26.
//

import Foundation
import CoreData
import UIKit

class CoreDataManager {
    
    static let shared = CoreDataManager()
    private init() {}

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "HealthDataModel")
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func saveContext () {
        if context.hasChanges {
            try? context.save()
        }
    }

    // MARK: - ALLERGIES
    func fetchAllergies() -> [AllergyEntity] {
        let request: NSFetchRequest<AllergyEntity> = AllergyEntity.fetchRequest()
        return (try? context.fetch(request)) ?? []
    }

    func addAllergy(_ allergy: Allergy) {
        let entity = AllergyEntity(context: context)
        entity.id = allergy.id ?? UUID() // Generate UUID if missing
        entity.name = allergy.name
        entity.severity = allergy.severity
        entity.notes = allergy.notes
        saveContext()
    }

    func deleteAllergy(id: UUID) {
        let request: NSFetchRequest<AllergyEntity> = AllergyEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        if let result = try? context.fetch(request), let entity = result.first {
            context.delete(entity)
            saveContext()
        }
    }

    // MARK: - MEALS
    func fetchMeals() -> [MealEntity] {
        let request: NSFetchRequest<MealEntity> = MealEntity.fetchRequest()
        return (try? context.fetch(request)) ?? []
    }

    func addMeal(_ meal: Meal) {
        let entity = MealEntity(context: context)
        entity.id = meal.id
        entity.name = meal.name
        entity.detail = meal.detail
        entity.time = meal.time
        entity.image = meal.image
        entity.type = meal.type
        entity.dateRecorded = meal.dateRecorded
        saveContext()
    }

    func deleteMeal(id: UUID) {
        let request: NSFetchRequest<MealEntity> = MealEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        if let result = try? context.fetch(request), let entity = result.first {
            context.delete(entity)
            saveContext()
        }
    }

    // MARK: - SYMPTOMS
    func fetchSymptoms() -> [SymptomEntity] {
        let request: NSFetchRequest<SymptomEntity> = SymptomEntity.fetchRequest()
        return (try? context.fetch(request)) ?? []
    }

    func addSymptom(_ symptom: Symptom) {
        let entity = SymptomEntity(context: context)
        entity.id = symptom.id ?? UUID()
        entity.symptomName = symptom.symptomName
        entity.intensity = symptom.intensity
        entity.dateRecorded = symptom.dateRecorded
        entity.notes = symptom.notes
        
        // Break down DateComponents into Ints for Core Data
        entity.timeHour = Int16(symptom.time.hour ?? 0)
        entity.timeMinute = Int16(symptom.time.minute ?? 0)
        
        saveContext()
    }

    func deleteSymptom(id: UUID) {
        let request: NSFetchRequest<SymptomEntity> = SymptomEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        if let result = try? context.fetch(request), let entity = result.first {
            context.delete(entity)
            saveContext()
        }
    }

    
        
        // Changed 'UserProfileEntity' to 'UserProfile' to match our Data Model
        func fetchUserProfile() -> UserProfile? {
            let request: NSFetchRequest<UserProfile> = UserProfile.fetchRequest()
            request.fetchLimit = 1
            return (try? context.fetch(request))?.first
        }

        func saveProfile(
            firstName: String,
            lastName: String,
            dob: Date,
            sex: String,
            diabetesType: String,
            bloodType: String,
            height: String,
            weight: String
        ) {
            // Changed 'UserProfileEntity' to 'UserProfile'
            let profile = fetchUserProfile() ?? UserProfile(context: context)
            
            profile.firstName = firstName
            profile.lastName = lastName
            profile.dob = dob
            profile.sex = sex
            profile.diabetesType = diabetesType
            profile.bloodType = bloodType
            profile.height = height
            profile.weight = weight
            
            saveContext()
        }
}
