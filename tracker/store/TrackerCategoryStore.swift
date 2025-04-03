
import CoreData

final class TrackerCategoryStore: NSObject, NSFetchedResultsControllerDelegate {
    
    static let shared = TrackerCategoryStore(context: PersistenceController.shared.context)
    
    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData>!
    
    var onUpdate: (() -> Void)?
    
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
        setupFetchedResultsController()
    }
    
    private func setupFetchedResultsController() {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("Ошибка загрузки категорий: \(error)")
        }
    }
    
    func fetchCategories() -> [TrackerCategoryCoreData] {
        return fetchedResultsController.fetchedObjects ?? []
    }
    
    func fetchCategory(byTitle title: String) -> TrackerCategoryCoreData? {
        return fetchedResultsController.fetchedObjects?.first(where: { $0.title == title })
    }
    
    func saveCategory(title: String) -> TrackerCategoryCoreData {
        let category = TrackerCategoryCoreData(context: context)
        category.title = title
        saveContext()
        return category
    }
    
    private func saveContext() {
        do {
            try context.save()
        } catch {
            print("Ошибка при сохранении категории: \(error)")
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        onUpdate?()
    }
}
