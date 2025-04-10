
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
}
