//
//  TrackerStructures.swift
//  tracker
//
//  Created by Anastasiia on 26.02.2025.
//

import UIKit

struct Tracker{
    let id: UUID
    let name: String
    let color: UIColor
    let emoji: String
    let calendar: [Weekday]
    let date: String?
}

struct TrackerCategory{
    let title: String
    let trakers: [Tracker]
}

struct TrackerRecord{
    let id: UUID
    let date: String
}

enum Weekday: String, Codable, CaseIterable {
    case Sunday = "Воскресенье"
    case Monday = "Понедельник"
    case Tuesday = "Вторник"
    case Wednesday = "Среда"
    case Thursday = "Четверг"
    case Friday = "Пятница"
    case Saturday = "Суббота"
    
    var shortName: String {
        switch self {
        case .Monday: return "Пн"
        case .Tuesday: return "Вт"
        case .Wednesday: return "Ср"
        case .Thursday: return "Чт"
        case .Friday: return "Пт"
        case .Saturday: return "Сб"
        case .Sunday: return "Вс"
        }
    }
}



