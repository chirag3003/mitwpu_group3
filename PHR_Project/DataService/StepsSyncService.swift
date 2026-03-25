import Foundation

final class StepsSyncService {
    static let shared = StepsSyncService()
    
    private init() {}
    
    func sync() {
        // Only sync if logged in
        guard AuthService.shared.isLoggedIn else { return }
        
        print("StepsSyncService: Starting sync...")
        
        // 1. Get last sync info from backend
        APIService.shared.request(endpoint: "/steps/last-updated", method: .get) { [weak self] (result: Result<LastSyncResponse, Error>) in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                self.processSync(with: response)
            case .failure(let error):
                print("StepsSyncService: Failed to fetch last sync info: \(error)")
            }
        }
    }
    
    private func processSync(with lastSync: LastSyncResponse) {
        // End date is always yesterday (today - 1 day)
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        guard let endDate = calendar.date(byAdding: .day, value: -1, to: today) else { return }
        
        // Start date from backend or fallback to 30 days ago
        let startDate: Date
        if let nextStart = lastSync.nextSyncStartDate {
            startDate = nextStart
        } else {
            startDate = calendar.date(byAdding: .day, value: -30, to: endDate) ?? endDate
        }
        
        // Check if we even need to sync (if startDate is after endDate)
        if startDate > endDate {
            print("StepsSyncService: Up to date. No sync needed.")
            return
        }
        
        print("StepsSyncService: Fetching steps from \(startDate) to \(endDate)")
        
        // 2. Fetch from HealthKit
        HealthKitService.shared.fetchStepHistory(from: startDate, to: endDate) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let dailySteps):
                self.uploadSteps(dailySteps)
            case .failure(let error):
                print("StepsSyncService: HealthKit fetch failed: \(error)")
            }
        }
    }
    
    private func uploadSteps(_ dailySteps: [Date: Int]) {
        guard !dailySteps.isEmpty else {
            print("StepsSyncService: No steps found in HealthKit for range.")
            return
        }
        
        let steps = dailySteps.map { (date, count) in
            StepData(dateRecorded: date, stepCount: count, source: "AppleHealthKit")
        }
        
        let syncRequest = StepSyncRequest(steps: steps)
        
        // 3. Post to backend
        APIService.shared.request(endpoint: "/steps/sync", method: .post, body: syncRequest) { (result: Result<StepSyncResult, Error>) in
            switch result {
            case .success(let result):
                print("StepsSyncService: Successfully synced \(result.synced) days of data.")
                NotificationCenter.default.post(name: NSNotification.Name(NotificationNames.stepsUpdated), object: nil)
            case .failure(let error):
                print("StepsSyncService: Failed to sync steps to backend: \(error)")
            }
        }
    }
}
