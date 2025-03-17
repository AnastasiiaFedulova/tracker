import Foundation

final class SceduleService {
    
    static let shared = SceduleService()
    
    var selectedWeekdays: [Weekday] = []
    
    private init() {}
}
