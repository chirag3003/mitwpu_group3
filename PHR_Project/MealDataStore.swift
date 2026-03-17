import Foundation

class MealDataStore {

    static let shared = MealDataStore()

    private var days: [CalendarDay] = []

    func getDays() -> [CalendarDay] {
        return days
    }

    private init() {
        self.days = generateNext30Days()
    }

    private func generateNext30Days() -> [CalendarDay] {
        var generatedDays: [CalendarDay] = []
        let calendar = Calendar.current
        let today = Date()
        let dateFormatter = DateFormatter()

        for i in -15...15 {
            if let date = calendar.date(byAdding: .day, value: i, to: today) {

                dateFormatter.dateFormat = "EEEEE"
                let dayString = dateFormatter.string(from: date)

                dateFormatter.dateFormat = "d"
                let numberString = dateFormatter.string(from: date)

                let dayObject = CalendarDay(
                    day: dayString,
                    number: numberString
                )
                generatedDays.append(dayObject)
            }
        }
        return generatedDays
    }
}
