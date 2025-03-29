
import CoreData

class TrackerRecordStore {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func saveRecord(forTracker tracker: TrackerCoreData, onDate date: Date) {
        let record = TrackerRecordCoreData(context: context)
        record.date = date
        record.tracker = tracker

        saveContext()
    }

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

    func deleteRecord(record: TrackerRecordCoreData) {
        context.delete(record)
        saveContext()
    }

    private func saveContext() {
        do {
            try context.save()
        } catch {
            print("Failed to save context: \(error)")
        }
    }
}
