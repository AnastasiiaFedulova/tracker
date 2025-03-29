//
//  PersistenceController.swift
//  tracker
//
//  Created by Anastasiia on 26.03.2025.
//

import Foundation
import CoreData

class PersistenceController {
    static let shared = PersistenceController()

    // Контейнер Core Data
    let container: NSPersistentContainer

    // Контекст, используемый для сохранения данных
    var context: NSManagedObjectContext {
        return container.viewContext
    }

    // Инициализация контейнера Core Data
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Model") // Укажи имя своей модели данных

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { description, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }

    // Сохранение контекста
    func saveContext() {
        let context = container.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
