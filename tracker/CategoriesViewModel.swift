import UIKit

final class CategoriesViewModel {
    private let categoriesServise = CategoriesServise.shared
    
    var categoriesDidChange: (() -> Void)?
    var selectedCategory: String?
    
    var categories: [String] {
        categoriesServise.categories
    }
    
    func loadCategories() {
        categoriesDidChange?()
    }
    
    func selectCategory(at index: Int) {
        selectedCategory = categories[index]
    }
    
    func deselectCategory() {
        selectedCategory = nil
    }
    
    func isSelectedCategory(at index: Int) -> Bool {
        selectedCategory == categories[index]
    }
    
    func updateSelectedCategory() {
        categoriesServise.updateSelectedCategory(selectedCategory ?? "")
    }
    
    func deleteCategory(at index: Int) {
        categoriesServise.categories.remove(at: index)
        categoriesServise.saveCategories()
        categoriesDidChange?()
    }
}
