//
//  treckerFactory.swift
//  tracker
//
//  Created by Anastasiia on 23.04.2025.
//

import Foundation

    final class TrackerFactory {
        static func makeNewFixedTrackers() -> [TrackerCategory] {
            let tracker1 = Tracker(
                id: UUID(uuidString: "11111111-1111-1111-1111-111111111111")!,
                name: "Купи собаку",
                color: .blue,
                emoji: "🐶",
                calendar: [.Monday, .Tuesday, .Wednesday, .Thursday, .Friday, .Saturday, .Sunday],
                date: "2025-04-27"
            )
        
            
            return [TrackerCategory(title: "Шаблон", trakers: [tracker1])]
        }
    }

