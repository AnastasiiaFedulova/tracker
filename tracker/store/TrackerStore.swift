//import CoreData
//
//// Протокол делегата
//protocol TrackerStoreDelegate: AnyObject {
//    func didUpdateTrackers()  // Уведомление UI об изменениях
//}
//
//class TrackerStore: CoreDataStore, NSFetchedResultsControllerDelegate {
//
//    private var fetchedResultsController: NSFetchedResultsController<TrackerCoreData>?
//    weak var delegate: TrackerStoreDelegate?
//
//    // Инициализация с передачей NSPersistentContainer
//    override init(persistentContainer: NSPersistentContainer) {
//        super.init(persistentContainer: persistentContainer)
//        setupFetchedResultsController()  // Настроить NSFetchedResultsController для отслеживания изменений
//    }
//
//    // Настройка NSFetchedResultsController для отслеживания изменений в трекерах
//    private func setupFetchedResultsController() {
//        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
//        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)] // Сортировка по имени
//
//        fetchedResultsController = NSFetchedResultsController(
//            fetchRequest: fetchRequest,
//            managedObjectContext: context,  // Используем контекст напрямую, он не nil
//            sectionNameKeyPath: nil,
//            cacheName: nil
//        )
//
//        fetchedResultsController?.delegate = self
//
//        do {
//            try fetchedResultsController?.performFetch()  // Загружаем данные
//        } catch {
//            print("Ошибка загрузки трекеров: \(error.localizedDescription)")
//        }
//    }
//
//    // Получение всех трекеров из Core Data
//    func getTrackers() -> [TrackerCoreData]? {
//        return fetchedResultsController?.fetchedObjects
//    }
//
//    // Добавление нового трекера
//    func addTracker(name: String, color: String, emoji: String, calendar: [Weekday]) {
//        let tracker = TrackerCoreData(context: context)  // Контекст всегда доступен
//        tracker.id = UUID()
//        tracker.name = name
//        tracker.color = color
//        tracker.emoji = emoji
//
//        // Преобразуем календарь в массив строк и сохраняем в Core Data
//        let calendarStrings = calendar.map { $0.rawValue } // преобразует enum в строки
//        tracker.calendar = NSSet(array: calendarStrings) // сохраняем как NSSet
//
//        saveContext()  // Сохраняем изменения в контексте
//    }
//
//    // Удаление трекера
//    func deleteTracker(_ tracker: TrackerCoreData) {
//        context.delete(tracker)  // Используем контекст напрямую
//        saveContext()  // Сохраняем контекст после удаления
//    }
//
//    func updateTrackerCompletion(id: String, isCompleted: Bool) {
//        let context = persistentContainer.viewContext
//        
//        // Загружаем трекер по ID
//        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
//        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
//        
//        do {
//            let results = try context.fetch(fetchRequest)
//            
//            // Если трекер найден, обновляем его состояние
//            if let tracker = results.first {
//                tracker.isCompleted = isCompleted  // Обновляем состояние
//                try context.save()  // Сохраняем изменения
//            }
//        } catch {
//            print("Ошибка при обновлении трекера: \(error.localizedDescription)")
//        }
//    }
//
//    // MARK: - NSFetchedResultsControllerDelegate
//
//    // Вызывается при изменении контента (добавление, удаление, обновление)
//    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        delegate?.didUpdateTrackers()  // Уведомляем делегата об изменениях
//    }
//
//    // Обработка конкретных изменений в данных
//    func controller(
//        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
//        didChange object: Any,
//        at indexPath: IndexPath?,
//        for type: NSFetchedResultsChangeType,
//        newIndexPath: IndexPath?)
//    {
//        switch type {
//        case .insert:
//            print("Добавлен новый трекер")
//        case .delete:
//            print("Удален трекер")
//        case .update:
//            print("Обновлен трекер")
//        case .move:
//            print("Перемещен трекер")
//        @unknown default:
//            print("Неизвестное изменение в Core Data")
//        }
//    }
//
//    // Сохранение изменений в контексте
//    internal override func saveContext() {
//        do {
//            if context.hasChanges {  // Прямо проверяем на изменения в контексте
//                try context.save()  // Сохраняем изменения в контексте
//            }
//        } catch {
//            print("Ошибка при сохранении контекста: \(error.localizedDescription)")
//        }
//    }
//}

import CoreData

class TrackerStore {
    static let shared = TrackerStore(context: PersistenceController.shared.context)
    
    private let context: NSManagedObjectContext
    
    // Инициализатор с контекстом
     init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    // Метод для сохранения трекера
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
            try context.save()  // Сохраняем контекст после добавления
            print("Трекер успешно сохранен в Core Data.")
        } catch {
            print("Ошибка сохранения в Core Data: \(error)")
        }
    }

    
    // Метод для получения трекера по id
//    func fetchTracker(id: UUID) {
//        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
//        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
//        
//        do {
//            let trackers = try context.fetch(fetchRequest)
//            if let tracker = trackers.first, let calendarData = tracker.calendar {
//                // Декодируем календарь
//                if let calendar = fetchCalendar(fromData: calendarData as! Data) {
//                    print("Календарь извлечен: \(calendar)")
//                } else {
//                    print("Не удалось декодировать календарь")
//                }
//            } else {
//                print("Трекер не найден или календарь отсутствует.")
//            }
//        } catch {
//            print("Ошибка при извлечении трекера: \(error)")
//        }
//    }
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
    
    // Метод для удаления трекера
    func deleteTracker(tracker: TrackerCoreData) {
        context.delete(tracker)
        saveContext()
    }
    
    // Метод для получения календаря трекера
    func getTrackerCalendar(tracker: TrackerCoreData) -> [Weekday]? {
        return fetchCalendar(fromData: tracker.calendar as! Data)
    }
    
    // Метод для декодирования календаря из Data
    private func fetchCalendar(fromData data: Data) -> [Weekday]? {
        do {
            let weekdays = try JSONDecoder().decode([Weekday].self, from: data)
            return weekdays
        } catch {
            print("Ошибка декодирования календаря: \(error)")
            return nil
        }
    }

    // Сохраняем изменения в контексте
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
    
    // Метод для получения категории по имени
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
    
    // Метод для создания новой категории
    func createCategory(name: String, context: NSManagedObjectContext) -> TrackerCategoryCoreData {
        let newCategory = TrackerCategoryCoreData(context: context)
        newCategory.title = name
        return newCategory
    }
}
