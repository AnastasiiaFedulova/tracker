//
//  AnalyticsService.swift
//  tracker
//
//  Created by Anastasiia on 28.04.2025.
//

import Foundation
import YandexMobileMetrica

final class AnalyticsService {
    static let shared = AnalyticsService()
    
    private init() {}
    
    func sendEvent(event: String, screen: String, item: String? = nil) {
        var parameters: [String: String] = [
            "event": event,
            "screen": screen
        ]
        
        if let item = item {
            parameters["item"] = item
        }
        
        YMMYandexMetrica.reportEvent("event", parameters: parameters)
        print("Analytics event sent: \(parameters)")
    }
}

