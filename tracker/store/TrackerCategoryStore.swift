//import Foundation
//import CoreData
//
//protocol TrackerCategoryStoreDelegate: AnyObject {
//    func didUpdateCategories()  // Уведомление UI об изменениях
//}
//
//class TrackerCategoryStore: NSObject, NSFetchedResultsControllerDelegate {
//    private let context: NSManagedObjectContext
//    private var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData>?
//    weak var delegate: TrackerCategoryStoreDelegate?  // Делегат для уведомлений
//
//    init(context: NSManagedObjectContext) {
//        self.context = context
//        super.init()
//        setupFetchedResultsController()
//    }
//
//    // Настройка NSFetchedResultsController
//    private func setupFetchedResultsController() {
//        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
//        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)] // Сортировка по названию категории
//
//        fetchedResultsController = NSFetchedResultsController(
//            fetchRequest: fetchRequest,
//            managedObjectContext: context,
//            sectionNameKeyPath: nil,
//            cacheName: nil
//        )
//
//        fetchedResultsController?.delegate = self  // Устанавливаем делегата
//
//        do {
//            try fetchedResultsController?.performFetch()
//        } catch {
//            print("Ошибка при загрузке категорий: \(error.localizedDescription)")
//        }
//    }
//
//    // Получить все категории
//    func getAllCategories() -> [TrackerCategoryCoreData]? {
//        return fetchedResultsController?.fetchedObjects
//    }
//
//    // Добавить новую категорию
//    func addCategory(title: String, trackers: [TrackerCoreData]) {
//        let category = TrackerCategoryCoreData(context: context)
//        category.title = title
//        category.addToTrackers(NSSet(array: trackers))  // Добавляем трекеры к категории
//
//        saveContext()
//    }
//
//    // Удалить категорию
//    func deleteCategory(_ category: TrackerCategoryCoreData) {
//        context.delete(category)
//        saveContext()
//    }
//
//    // Сохранить изменения в контексте
//    private func saveContext() {
//        do {
//            if context.hasChanges {
//                try context.save()
//            }
//        } catch {
//            print("Ошибка при сохранении контекста: \(error.localizedDescription)")
//        }
//    }
//
//    // MARK: - NSFetchedResultsControllerDelegate
//
//    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        delegate?.didUpdateCategories()  // Уведомление делегата об изменениях
//    }
//
//    func controller(
//        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
//        didChange object: Any,
//        at indexPath: IndexPath?,
//        for type: NSFetchedResultsChangeType,
//        newIndexPath: IndexPath?)
//    {
//        switch type {
//        case .insert:
//            print("Добавлена новая категория")
//        case .delete:
//            print("Удалена категория")
//        case .update:
//            print("Обновлена категория")
//        case .move:
//            print("Перемещена категория")
//        @unknown default:
//            print("Неизвестное изменение в Core Data")
//        }
//    }
//}

import CoreData
class TrackerCategoryStore {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    // Метод для получения категории по названию
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
    
    // Метод для сохранения новой категории
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
