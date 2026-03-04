import Foundation
import SwiftUI
import Combine

enum ChartTimeRange {
    case day, week, month, sixMonth, year
}

class ChartViewModel: ObservableObject {
    @Published var dataPoints: [GlucoseDataPoint] = []
    
    @Published var currentRange: ChartTimeRange = .week
}
