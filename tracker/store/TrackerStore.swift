
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
    func fetchTracker(byID id: UUID, context: NSManagedObjectContext) -> TrackerCoreData? {
        let request = TrackerCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1

        return try? context.fetch(request).first
    }

    
    func createCategory(name: String, context: NSManagedObjectContext) -> TrackerCategoryCoreData {
        let newCategory = TrackerCategoryCoreData(context: context)
        newCategory.title = name
        return newCategory
    }
    
}
import CoreData

final class TrackerStore: NSObject, NSFetchedResultsControllerDelegate {
    static let shared = TrackerStore(context: PersistenceController.shared.context)
    
    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerCoreData>!
    
    var onUpdate: (() -> Void)?
    
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
        setupFetchedResultsController()
    }
    
    private func setupFetchedResultsController() {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
            print("Perform fetch successful, fetched objects: \(fetchedResultsController.fetchedObjects?.count ?? 0)")
        } catch {
            print("Ошибка загрузки данных: \(error)")
        }
    }
    
    func getTrackers() -> [TrackerCoreData] {
        return fetchedResultsController.fetchedObjects ?? []
    }
    
    func saveTracker(name: String, color: String, emoji: String, calendarData: Data, category: TrackerCategoryCoreData?, isCompleted: Bool) {
        let newTracker = TrackerCoreData(context: context)
        newTracker.id = UUID()
        newTracker.name = name
        newTracker.color = color
        newTracker.emoji = emoji
        newTracker.calendar = calendarData as NSData
        newTracker.isCompleted = isCompleted
        newTracker.category = category
        
        saveContext()
    }
    
    func deleteTracker(tracker: TrackerCoreData) {
        print("Удаление трекера: \(tracker.name ?? "Без имени")")
        context.delete(tracker)
        saveContext()
    }

    
    func getTrackerCalendar(tracker: TrackerCoreData) -> [Weekday]? {
        return fetchCalendar(fromData: tracker.calendar as! Data)
    }
    
    private func fetchCalendar(fromData data: Data) -> [Weekday]? {
        do {
            return try JSONDecoder().decode([Weekday].self, from: data)
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
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        onUpdate?()
    }
    func fetchTrackerCoreData(by id: UUID) throws -> TrackerCoreData? {
        let fetchRequest = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        fetchRequest.fetchLimit = 1
        let results = try context.fetch(fetchRequest)
        return results.first
    }
    
    func clearAll() {
        let trackerRequest: NSFetchRequest<NSFetchRequestResult> = TrackerCoreData.fetchRequest()
        let categoryRequest: NSFetchRequest<NSFetchRequestResult> = TrackerCategoryCoreData.fetchRequest()
        
        do {
            try context.execute(NSBatchDeleteRequest(fetchRequest: trackerRequest))
            try context.execute(NSBatchDeleteRequest(fetchRequest: categoryRequest))
            try context.save()
            context.reset()
            print("✅ Очистка выполнена")

            reloadFetchedResults() // Обновляем FRC
            onUpdate?() // Обновляем UI
        } catch {
            print("❌ Ошибка очистки: \(error)")
        }
    }

    func reloadFetchedResults() {
        setupFetchedResultsController()
        onUpdate?()
    }


    
//    func save(categories: [TrackerCategory]) {
//        for category in categories {
//            // Используем существующую категорию, если есть
//            let categoryCoreData: TrackerCategoryCoreData
//            if let existingCategory = CoreDataService.shared.fetchCategory(byName: category.title, context: context) {
//                categoryCoreData = existingCategory
//            } else {
//                categoryCoreData = CoreDataService.shared.createCategory(name: category.title, context: context)
//            }
//            
//            for tracker in category.trakers {
//                // Проверяем, существует ли трекер с таким ID
//                if let existingTracker = try? fetchTrackerCoreData(by: tracker.id) {
//                    // Проверяем, не прикреплён ли он уже к этой категории
//                    if existingTracker.category == categoryCoreData {
//                        continue // уже сохранён и прикреплён — пропускаем
//                    } else {
//                        existingTracker.category = categoryCoreData
//                        continue // просто переподключаем — не создаём
//                    }
//                }
//                
//                // Если трекер не существует — создаём
//                save(tracker: tracker, category: categoryCoreData)
//            }
//        }
//        
//        saveContext()
//    }
    
    func save(categories: [TrackerCategory]) {
        for category in categories {
            let existingCategory = TrackerCategoryStore.shared.fetchCategory(byTitle: category.title)
            let categoryCoreData: TrackerCategoryCoreData
            
            if let existing = existingCategory {
                categoryCoreData = existing
            } else {
                categoryCoreData = TrackerCategoryCoreData(context: context)
                categoryCoreData.title = category.title
            }

            for tracker in category.trakers {
                let trackerCoreData = TrackerCoreData(context: context)
                trackerCoreData.id = tracker.id
                trackerCoreData.name = tracker.name
                trackerCoreData.color = tracker.color.toHex()
                trackerCoreData.emoji = tracker.emoji
                trackerCoreData.calendar = tracker.calendar.map { $0.rawValue } as NSObject
                trackerCoreData.date = tracker.date
                trackerCoreData.category = categoryCoreData
            }
        }

        do {
            try context.save()
        } catch {
            print("Ошибка при сохранении: \(error)")
        }
    }
    func saveFixedTrackersForTest() {
        // Создаем одну категорию и один трекер для теста
        let category = TrackerCategory(title: "Test Category", trakers: [
            Tracker(id: UUID(), name: "Купи собаку", color: .blue, emoji: "🐶", calendar: [], date: nil)
        ])
        
        // Очистить все старые данные перед сохранением
        clearAll()
        
        // Сохраняем новую категорию с трекером
        save(categories: [category])
        
        // Для проверки добавления
        print("Создан новый трекер: \(category.trakers.first?.name ?? "Без названия")")
    }



    private func save(tracker: Tracker, category: TrackerCategoryCoreData) {
        if let existingTracker = try? fetchTrackerCoreData(by: tracker.id) {
            // Обновляем
            existingTracker.name = tracker.name
            existingTracker.color = tracker.color.toHex()
            existingTracker.emoji = tracker.emoji
            existingTracker.calendar = try? JSONEncoder().encode(tracker.calendar) as NSData?
            existingTracker.isCompleted = false
            existingTracker.category = category
        } else {
            // Создаем
            let trackerCoreData = TrackerCoreData(context: context)
            trackerCoreData.id = tracker.id
            trackerCoreData.name = tracker.name
            trackerCoreData.color = tracker.color.toHex()
            trackerCoreData.emoji = tracker.emoji
            trackerCoreData.calendar = try? JSONEncoder().encode(tracker.calendar) as NSData?
            trackerCoreData.isCompleted = false
            trackerCoreData.category = category
        }
    }

}
