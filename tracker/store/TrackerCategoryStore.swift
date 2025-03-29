
import CoreData

class TrackerCategoryStore {
    
    static let shared = TrackerCategoryStore(context: PersistenceController.shared.context)
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func fetchCategory(byTitle title: String) -> TrackerCategoryCoreData? {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@", title)
        
        do {
            let categories = try context.fetch(fetchRequest)
            return categories.first
        } catch {
            print("Ошибка при получении категории: \(error)")
            return nil
        }
    }

    func fetchCategories() -> [TrackerCategoryCoreData] {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        
        do {
            let categories = try context.fetch(fetchRequest)
            return categories
        } catch {
            print("Ошибка при получении категории: \(error)")
            return []
        }
    }
    
    func saveCategory(title: String) -> TrackerCategoryCoreData {
        let category = TrackerCategoryCoreData(context: context)
        category.title = title
        
        do {
            try context.save()
        } catch {
            print("Ошибка при сохранении категории: \(error)")
        }
        
        return category
    }
}
