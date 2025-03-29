
import CoreData

class TrackerStore {
    static let shared = TrackerStore(context: PersistenceController.shared.context)
    
    private let context: NSManagedObjectContext
    
     init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func saveTracker(name: String, color: String, emoji: String, calendarData: NSData, category: TrackerCategoryCoreData?, isCompleted: Bool, context: NSManagedObjectContext) {
        let newTracker = TrackerCoreData(context: context)
        newTracker.id = UUID()
        newTracker.name = name
        newTracker.color = color
        newTracker.emoji = emoji
        newTracker.calendar = calendarData
        newTracker.isCompleted = isCompleted
        newTracker.category = category
        
        do {
            try context.save()
            print("Трекер успешно сохранен в Core Data.")
        } catch {
            print("Ошибка сохранения в Core Data: \(error)")
        }
    }
    
    func fetchTrackers() -> [TrackerCoreData]? {
            let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
            
            do {
                let trackers = try context.fetch(fetchRequest)
                return trackers
            } catch {
                print("Ошибка при загрузке данных: \(error)")
                return nil
            }
        }
    
    func deleteTracker(tracker: TrackerCoreData) {
        context.delete(tracker)
        saveContext()
    }
    
    func getTrackerCalendar(tracker: TrackerCoreData) -> [Weekday]? {
        return fetchCalendar(fromData: tracker.calendar as! Data)
    }

    private func fetchCalendar(fromData data: Data) -> [Weekday]? {
        do {
            let weekdays = try JSONDecoder().decode([Weekday].self, from: data)
            return weekdays
        } catch {
            print("Ошибка декодирования календаря: \(error)")
            return nil
        }
    }

    private func saveContext() {
        do {
            try context.save()
        } catch {
            print("Ошибка при сохранении контекста: \(error)")
        }
    }
}


class CoreDataService {
    static let shared = CoreDataService()
    
    private init() {}

    func fetchCategory(byName name: String, context: NSManagedObjectContext) -> TrackerCategoryCoreData? {
        let categoryFetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        categoryFetchRequest.predicate = NSPredicate(format: "title == %@", name)
        
        do {
            let categories = try context.fetch(categoryFetchRequest)
            return categories.first
        } catch {
            print("Ошибка при поиске категории: \(error)")
            return nil
        }
    }

    func createCategory(name: String, context: NSManagedObjectContext) -> TrackerCategoryCoreData {
        let newCategory = TrackerCategoryCoreData(context: context)
        newCategory.title = name
        return newCategory
    }
}
