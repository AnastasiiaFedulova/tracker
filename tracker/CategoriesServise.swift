import Foundation

final class CategoriesServise {
    
    static let shared = CategoriesServise()
    
    private let categoriesKey = "savedCategories"
    
    static let didChangeNotification = Notification.Name(rawValue: "CategoriesDidChange")
    static let didChangeCategories = Notification.Name(rawValue: "AddCategories")
    
    private init() {
        loadCategories()
    }
    
    var categories: [String] = []
    
    var selectedCategory: String?
    
    func addCategories(_ category: String) {
        
        categories.append(category)
        saveCategories()
        
        NotificationCenter.default.post(name: CategoriesServise.didChangeNotification, object: nil)
    }
    
    func updateSelectedCategory(_ category: String) {
        selectedCategory = category
    }
    
    private func loadCategories() {
        if let savedCategories = UserDefaults.standard.array(forKey: categoriesKey) as? [String] {
            categories = savedCategories
        }
    }
    
    func saveCategories() {
        UserDefaults.standard.set(categories, forKey: categoriesKey)
        NotificationCenter.default.post(name: CategoriesServise.didChangeNotification, object: nil)
    }
    
    func showCategories() -> [String] {
        return categories
    }
    
    func updateName(oldName: String?, newName: String) {
        if categories.isEmpty == false {
            for i in 0..<categories.count {
                if categories[i] == oldName {
                    categories[i] = newName
                }
            }
        }
    }
}
