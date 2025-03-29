//
//  store.swift
//  tracker
//
//  Created by Anastasiia on 24.03.2025.
//

import CoreData

class CoreDataStore: NSObject {
    let persistentContainer: NSPersistentContainer
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    init(persistentContainer: NSPersistentContainer) {
        self.persistentContainer = persistentContainer
    }

    func saveContext() {
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            print("Ошибка сохранения контекста: \(error.localizedDescription)")
        }
    }
}
