import CoreData
import Foundation
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

    func saveContext() {
        if context.hasChanges {
            try? context.save()
        }
    }

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

    // MARK: - WATER INTAKE

    // Helper to fetch the entity for a specific date (ignoring time)
    func fetchWaterIntake(for date: Date) -> WaterIntakeEntity? {
        let request: NSFetchRequest<WaterIntakeEntity> =
            WaterIntakeEntity.fetchRequest()

        // Get start and end of the day to filter correctly
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        // Predicate: Date is >= Start AND Date < End
        request.predicate = NSPredicate(
            format: "date >= %@ AND date < %@",
            startOfDay as NSDate,
            endOfDay as NSDate
        )
        request.fetchLimit = 1

        return (try? context.fetch(request))?.first
    }

    func saveWaterIntake(count: Int, date: Date) {
        // Check if we already have a record for today
        let entity: WaterIntakeEntity

        if let existing = fetchWaterIntake(for: date) {
            entity = existing
        } else {
            // If no record for today, create a new one
            entity = WaterIntakeEntity(context: context)
            entity.date = date
        }

        // Update the count
        entity.count = Int16(count)
        saveContext()
    }

}
