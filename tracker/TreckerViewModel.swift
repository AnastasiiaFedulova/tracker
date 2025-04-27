//
//  TreckerViewModel.swift
//  tracker
//
//  Created by Anastasiia on 23.04.2025.
//

import Foundation

final class TrackerViewModel {
    private let store: TrackerStore

    init(store: TrackerStore = .shared) {
        self.store = store
    }

    /// Очищает все трекеры
    func deleteAll() {
        store.clearAll()
    }

    /// Загружает фиксированные трекеры для тестов (1 категория, 1 трекер)
//    func loadFixedTrackersForTest() {
//        store.clearAll()
//        let fixedCategories = TrackerFactory.makeNewFixedTrackers()
//        store.save(categories: fixedCategories)
//    }
    func loadFixedTrackersForTest() {
        store.clearAll()
        
        let fixedCategories = TrackerFactory.makeNewFixedTrackers()
        for category in fixedCategories {
            store.save(categories: [category]) // сохраняем категории
        }
        
        store.reloadFetchedResults() // обновляем FRC
        store.onUpdate?() // Обновляем UI
    }



    /// Метод для отладки — загружает те же фиксированные трекеры
    func loadFixedTrackers() {
        loadFixedTrackersForTest()
    }
    
}
