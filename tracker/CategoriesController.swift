import UIKit

final class CategoriesController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private let viewModel = CategoriesViewModel()
    
    var nameOfChuseCategory: String?
    private let tableView = UITableView()
    private let starImage = UIImageView(image: UIImage(named: "star"))
    private let labelStar = UILabel()
    private let tableViewContainer = UIView()
    private var tableViewContainerHeightConstraint: NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupUI()
        bindViewModel()
        viewModel.loadCategories()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateCategories),
            name: CategoriesServise.didChangeCategories,
            object: nil
        )
    }
    
    @objc private func updateCategories() {
        viewModel.loadCategories()
    }
    
    private func bindViewModel() {
        viewModel.categoriesDidChange = { [weak self] in
            self?.showCategories()
        }
    }
    
    private func setupUI() {
        let categoriesLabel = UILabel()
        categoriesLabel.textColor = .black
        categoriesLabel.text = "Категория"
        categoriesLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        categoriesLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(categoriesLabel)
        
        NSLayoutConstraint.activate([
            categoriesLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            categoriesLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 38)
        ])
        
        tableViewContainer.translatesAutoresizingMaskIntoConstraints = false
        tableViewContainer.layer.cornerRadius = 0
        tableViewContainer.layer.masksToBounds = true
        tableViewContainer.backgroundColor = .clear
        view.addSubview(tableViewContainer)
        tableViewContainerHeightConstraint = tableViewContainer.heightAnchor.constraint(equalToConstant: 0)
        tableViewContainerHeightConstraint?.isActive = true
        
        NSLayoutConstraint.activate([
            tableViewContainer.topAnchor.constraint(equalTo: categoriesLabel.bottomAnchor, constant: 20),
            tableViewContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableViewContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none

        
        tableView.layer.cornerRadius = 16
        tableView.layer.maskedCorners = [
            .layerMinXMinYCorner,
            .layerMaxXMinYCorner,
            .layerMinXMaxYCorner,
            .layerMaxXMaxYCorner
        ]
        tableView.layer.masksToBounds = true
        tableView.backgroundColor = .gr
        tableView.register(CategoryCell.self, forCellReuseIdentifier: "CategoryCell")
        
        tableView.isHidden = true
        tableViewContainer.addSubview(tableView)
        tableView.contentInset = .zero
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.tableFooterView = UIView(frame: .zero)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: tableViewContainer.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: tableViewContainer.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: tableViewContainer.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: tableViewContainer.bottomAnchor)
        ])
        
        starImage.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(starImage)
        
        NSLayoutConstraint.activate([
            starImage.heightAnchor.constraint(equalToConstant: 80),
            starImage.widthAnchor.constraint(equalToConstant: 80),
            starImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            starImage.topAnchor.constraint(equalTo: categoriesLabel.bottomAnchor, constant: 246)
        ])
        
        labelStar.text = "Привычки и события можно \n объединить по смыслу"
        labelStar.numberOfLines = 0
        labelStar.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        labelStar.textColor = .black
        labelStar.textAlignment = .center
        labelStar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(labelStar)
        
        NSLayoutConstraint.activate([
            labelStar.topAnchor.constraint(equalTo: starImage.bottomAnchor, constant: 8),
            labelStar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            labelStar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
        
        let addCategoryButton = UIButton(type: .system)
        addCategoryButton.setTitle("Добавить категорию", for: .normal)
        addCategoryButton.setTitleColor(.white, for: .normal)
        addCategoryButton.backgroundColor = .black
        addCategoryButton.layer.cornerRadius = 16
        addCategoryButton.translatesAutoresizingMaskIntoConstraints = false
        addCategoryButton.addTarget(self, action: #selector(didTapaddCategoryButton), for: .touchUpInside)
        view.addSubview(addCategoryButton)
        
        addCategoryButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        
        NSLayoutConstraint.activate([
            addCategoryButton.heightAnchor.constraint(equalToConstant: 60),
            addCategoryButton.widthAnchor.constraint(equalToConstant: 335),
            addCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
    
    func showCategories() {
        let categories = viewModel.categories
        
        if categories.isEmpty {
            tableView.isHidden = true
            starImage.isHidden = false
            labelStar.isHidden = false
        } else {
            tableView.isHidden = false
            starImage.isHidden = true
            labelStar.isHidden = true
            
            tableView.reloadData()
            
            let newHeight = CGFloat(categories.count) * 75
            tableViewContainerHeightConstraint?.constant = newHeight
            
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as! CategoryCell
        let category = viewModel.categories[indexPath.row]
        cell.textLabel?.text = category
        cell.tag = indexPath.row
        
        let isLast = indexPath.row == viewModel.categories.count - 1
        cell.hideSeparator(isLast)
        
        cell.backgroundColor = .gr
        cell.selectionStyle = .none
        cell.accessoryType = viewModel.isSelectedCategory(at: indexPath.row) ? .checkmark : .none
        
        let interaction = UIContextMenuInteraction(delegate: self)
        cell.addInteraction(interaction)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if viewModel.isSelectedCategory(at: indexPath.row) {
            viewModel.deselectCategory()
        } else {
            viewModel.selectCategory(at: indexPath.row)
        }
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    @objc func didTapaddCategoryButton() {
        if let selected = viewModel.selectedCategory {
            nameOfChuseCategory = selected
            viewModel.updateSelectedCategory()
            
            NotificationCenter.default.post(name: CategoriesServise.didChangeCategories, object: nil)
            
            dismiss(animated: true)
        } else {
            let createCategoriesController = CreateCategoriesController()
            createCategoriesController.modalPresentationStyle = .automatic
            present(createCategoriesController, animated: true)
        }
    }
}

extension CategoriesController: UIContextMenuInteractionDelegate {
    
    func contextMenuInteraction(
        _ interaction: UIContextMenuInteraction,
        configurationForMenuAtLocation location: CGPoint
    ) -> UIContextMenuConfiguration? {
        guard let cell = interaction.view as? UITableViewCell else { return nil }
        let index = cell.tag
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in
            guard let self = self else { return UIMenu(title: "", children: []) }
            
            let editAction = UIAction(title: "Редактировать") { _ in
                let editCategoriesController = EditCategoriesController()
                editCategoriesController.categoriesName = self.viewModel.categories[index]
                editCategoriesController.modalPresentationStyle = .automatic
                editCategoriesController.onCategoryUpdated = {
                                self.viewModel.loadCategories()
                            }
                self.present(editCategoriesController, animated: true, completion: nil)
            }
            
            let deleteAction = UIAction(title: "Удалить", attributes: .destructive) { _ in
                self.viewModel.deleteCategory(at: index)
            }
            
            return UIMenu(title: "", children: [editAction, deleteAction])
        }
    }
}

