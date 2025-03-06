//
//  TrackerStructures.swift
//  tracker
//
//  Created by Anastasiia on 26.02.2025.
//

import Foundation

struct Tracker {
    let id: UUID
    let name: String
    let color: String
    let emoji: String
    let calendar: [Weekday]
}

struct TrackerCategory {
    let title: String
    let trakers: [Tracker]
}

struct TrackerRecord {
    let id: UUID
    let date: String
}

enum Weekday: String {
    case Monday = "Понедельник"
    case Tuesday = "Вторник"
    case Wednesday = "Среда"
    case Thursday = "Четверг"
    case Friday = "Пятница"
    case Saturday = "Суббота"
    case Sunday = "Воскресенье"
}


