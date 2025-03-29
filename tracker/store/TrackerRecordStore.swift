//import Foundation
//import CoreData
//
//protocol TrackerRecordStoreDelegate: AnyObject {
//    func didUpdateRecords()  // Метод для уведомления об изменениях в записях
//}
//
//class TrackerRecordStore: NSObject, NSFetchedResultsControllerDelegate {
//    private let context: NSManagedObjectContext
//    private var fetchedResultsController: NSFetchedResultsController<TrackerRecordCoreData>?
//    
//    weak var delegate: TrackerRecordStoreDelegate?  // Делегат для уведомления об изменениях
//    
//    init(context: NSManagedObjectContext) {
//        self.context = context
//        super.init()
//        setupFetchedResultsController()
//    }
//    
//    // Настройка NSFetchedResultsController для отслеживания изменений
//    private func setupFetchedResultsController() {
//        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
//        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]  // Сортировка по дате
//        
//        fetchedResultsController = NSFetchedResultsController(
//            fetchRequest: fetchRequest,
//            managedObjectContext: context,
//            sectionNameKeyPath: nil,
//            cacheName: nil
//        )
//        
//        fetchedResultsController?.delegate = self  // Устанавливаем делегат для отслеживания изменений
//        
//        do {
//            try fetchedResultsController?.performFetch()  // Загружаем данные
//        } catch {
//            print("Ошибка загрузки записей: \(error.localizedDescription)")
//        }
//    }
//    
//    // Получить все записи
//    func getAllRecords() -> [TrackerRecordCoreData]? {
//        return fetchedResultsController?.fetchedObjects
//    }
//    
//    // Добавить новую запись
//    func addRecord(dateString: String, tracker: TrackerCoreData) {
//        let record = TrackerRecordCoreData(context: context)
//        record.id = UUID()
//        record.date = convertStringToDate(dateString)  // Преобразуем строку в Date
//        record.tracker = tracker
//        
//        saveContext()
//    }
//    
//    // Удалить запись
//    func deleteRecord(_ record: TrackerRecordCoreData) {
//        context.delete(record)
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
//    // Преобразование строки в объект Date
//    private func convertStringToDate(_ dateString: String) -> Date? {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd"  // Установите формат в зависимости от того, как хранится ваша строка
//        return dateFormatter.date(from: dateString)
//    }
//    
//    // MARK: - NSFetchedResultsControllerDelegate
//    
//    // Метод вызывается при изменении контента (например, обновление, добавление, удаление)
//    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        print("Core Data обновила данные записей!")
//        delegate?.didUpdateRecords()  // Уведомление делегата об изменениях
//    }
//    
//    // Метод для обработки конкретных изменений
//    func controller(
//        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
//        didChange object: Any,
//        at indexPath: IndexPath?,
//        for type: NSFetchedResultsChangeType,
//        newIndexPath: IndexPath?)
//    {
//        switch type {
//        case .insert:
//            print("Добавлена новая запись")
//        case .delete:
//            print("Удалена запись")
//        case .update:
//            print("Обновлена запись")
//        case .move:
//            print("Перемещена запись")
//        @unknown default:
//            print("Неизвестное изменение в Core Data")
//        }
//    }
//}
import CoreData

class TrackerRecordStore {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    // Сохраняем новую запись для трекера
    func saveRecord(forTracker tracker: TrackerCoreData, onDate date: Date) {
        let record = TrackerRecordCoreData(context: context)
        record.date = date
        record.tracker = tracker // Связываем запись с трекером

        saveContext()
    }

    // Извлекаем все записи для конкретного трекера
    func fetchRecords(forTracker tracker: TrackerCoreData) -> [TrackerRecordCoreData] {
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "tracker == %@", tracker)
        do {
            let records = try context.fetch(fetchRequest)
            return records
        } catch {
            print("Failed to fetch records: \(error)")
            return []
        }
    }

    // Удаляем запись
    func deleteRecord(record: TrackerRecordCoreData) {
        context.delete(record)
        saveContext()
    }

    // Сохраняем изменения в контексте
    private func saveContext() {
        do {
            try context.save()
        } catch {
            print("Failed to save context: \(error)")
        }
    }
}
