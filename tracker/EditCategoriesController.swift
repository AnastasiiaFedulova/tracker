//
//  EditCategoriesController.swift
//  tracker
//
//  Created by Anastasiia on 02.03.2025.
//

import Foundation
import UIKit

final class EditCategoriesController: UIViewController, UITextFieldDelegate {
    
    var categoriesName: String?
    private let clearButton = UIButton(type: .custom)
    let name = UITextField()
    let categoriesServise = CategoriesServise.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupClearButton()
        name.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        view.backgroundColor = .white
        
        let editcategoriesLabel = UILabel()
        editcategoriesLabel.textColor = .black
        editcategoriesLabel.text = "Редактирование категории"
        editcategoriesLabel.font = .boldSystemFont(ofSize: 16)
        editcategoriesLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(editcategoriesLabel)
        
        NSLayoutConstraint.activate([
            editcategoriesLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            editcategoriesLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 38)
        ])
        
        name.text = categoriesName
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
            name.topAnchor.constraint(equalTo: editcategoriesLabel.bottomAnchor, constant: 38)
        ])
        
        let doneButton = UIButton(type: .system)
        doneButton.setTitle("Готово", for: .normal)
        doneButton.setTitleColor(.white, for: .normal)
        doneButton.backgroundColor = .black
        doneButton.layer.cornerRadius = 16
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        doneButton.addTarget(self, action: #selector(didTapdoneButton), for: .touchUpInside)
        view.addSubview(doneButton)
        
        NSLayoutConstraint.activate([
            doneButton.heightAnchor.constraint(equalToConstant: 60),
            doneButton.widthAnchor.constraint(equalToConstant: 335),
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.topAnchor.constraint(equalTo: editcategoriesLabel.bottomAnchor, constant: 602)
        ])
        
    }
    
    @objc func didTapdoneButton() {
        var newName = name.text ?? ""
        
        if let oldName = categoriesName {
            categoriesServise.updateName(oldName: oldName, newName: newName)
            categoriesServise.saveCategories()
        }
        dismiss(animated: true)
    }
    
    @objc private func clearTextField() {
        name.text = ""
        clearButton.isHidden = true
    }
    @objc private func textFieldDidChange() {
        clearButton.isHidden = name.text?.isEmpty ?? true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
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
    
    
}
