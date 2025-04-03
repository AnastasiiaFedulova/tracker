import UIKit

final class CreateCategoriesController: UIViewController, UITextFieldDelegate {
    
    
    let categoriesController = CategoriesController()
    let categoriesServise = CategoriesServise.shared
    let name = UITextField()
    private let clearButton = UIButton(type: .custom)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        setupClearButton()
        name.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    private func setupUI() {
        let newCategoryLabel = UILabel()
        newCategoryLabel.textColor = .black
        newCategoryLabel.text = "Новая категория"
        newCategoryLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        newCategoryLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(newCategoryLabel)
        
        NSLayoutConstraint.activate([
            newCategoryLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            newCategoryLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 38)
        ])
        
        name.placeholder = "Введите название категории"
        name.borderStyle = .roundedRect
        name.textColor = .black
        name.backgroundColor = .gr
        name.layer.cornerRadius = 16
        name.layer.masksToBounds = true
        name.translatesAutoresizingMaskIntoConstraints = false
        name.returnKeyType = .done
        name.delegate = self
        view.addSubview(name)
        
        NSLayoutConstraint.activate([
            name.widthAnchor.constraint(equalToConstant: 343),
            name.heightAnchor.constraint(equalToConstant: 75),
            name.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            name.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            name.topAnchor.constraint(equalTo: newCategoryLabel.bottomAnchor, constant: 38)
        ])
        
        let doneButton = UIButton(type: .system)
        doneButton.setTitle("Готово", for: .normal)
        doneButton.setTitleColor(.white, for: .normal)
        doneButton.backgroundColor = .black
        doneButton.layer.cornerRadius = 16
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        doneButton.addTarget(self, action: #selector(didTapdoneButton), for: .touchUpInside)
        view.addSubview(doneButton)
        
        doneButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        
        NSLayoutConstraint.activate([
            doneButton.heightAnchor.constraint(equalToConstant: 60),
            doneButton.widthAnchor.constraint(equalToConstant: 335),
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
    
    private func setupClearButton() {
        clearButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        clearButton.tintColor = .gray
        clearButton.addTarget(self, action: #selector(clearTextField), for: .touchUpInside)
        clearButton.frame = CGRect(x: 0, y: 0, width: 17, height: 17)
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 29, height: 75))
        clearButton.center = CGPoint(x: paddingView.frame.width - 12 - 8.5, y: paddingView.frame.height / 2)
        paddingView.addSubview(clearButton)
        
        name.rightView = paddingView
        name.rightViewMode = .whileEditing
        clearButton.isHidden = true
    }
    
    @objc private func textFieldDidChange() {
        clearButton.isHidden = name.text?.isEmpty ?? true
    }
    
    @objc private func clearTextField() {
        name.text = ""
        clearButton.isHidden = true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc private func didTapdoneButton() {
        guard let categoryName = name.text, !categoryName.isEmpty else {
            print("Название категории не может быть пустым")
            return
        }
        
        categoriesServise.addCategories(categoryName)
        
        NotificationCenter.default.post(name: CategoriesServise.didChangeCategories, object: nil)
        
        dismiss(animated: true)
    }
}
