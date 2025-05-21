//
//  AppDelegate.swift
//  tracker
//
//  Created by Anastasiia on 26.02.2025.
//
import UIKit
import YandexMobileMetrica

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let configuration = YMMYandexMetricaConfiguration(apiKey: "3adda921-33b3-4390-b177-491b95de0a1a")
        YMMYandexMetrica.activate(with: configuration!)
        
        let viewController = ViewController()
        window = UIWindow()
        window?.rootViewController = viewController
        window?.makeKeyAndVisible()
        
        return true
    }
}
