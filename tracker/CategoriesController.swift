import UIKit


final class CategoriesController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let categoriesServise = CategoriesServise.shared
    
    private let tableView = UITableView()
    private let starImage = UIImageView(image: UIImage(named: "star"))
    private let labelStar = UILabel()
    private let tableViewContainer = UIView()
    private let tableData = [""]
    
    private var currentSelectedCell: UITableViewCell? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupUI()
        showCategories()
        
        NotificationCenter.default
            .addObserver(
                forName: CategoriesServise.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else { return }
                
                showCategories()
            }
    }
    
    private func setupUI() {
        let categoriesLabel = UILabel()
        categoriesLabel.textColor = .black
        categoriesLabel.text = "Категория"
        categoriesLabel.font = .boldSystemFont(ofSize: 16)
        categoriesLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(categoriesLabel)
        
        NSLayoutConstraint.activate([
            categoriesLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            categoriesLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 38)
        ])
        
        tableViewContainer.translatesAutoresizingMaskIntoConstraints = false
        tableViewContainer.layer.cornerRadius = 16
        tableViewContainer.layer.masksToBounds = true
        tableViewContainer.backgroundColor = .gr
        view.addSubview(tableViewContainer)
        
        NSLayoutConstraint.activate([
            tableViewContainer.heightAnchor.constraint(equalToConstant: CGFloat(categoriesServise.categories.count * 75)),
            tableViewContainer.topAnchor.constraint(equalTo: categoriesLabel.bottomAnchor, constant: 20),
            tableViewContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableViewContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CategoryCell")
        tableView.isHidden = true
        tableViewContainer.addSubview(tableView)
        
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
        labelStar.font = .boldSystemFont(ofSize: 12)
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
        
        NSLayoutConstraint.activate([
            addCategoryButton.heightAnchor.constraint(equalToConstant: 60),
            addCategoryButton.widthAnchor.constraint(equalToConstant: 335),
            addCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
        
    }

    func showCategories() {
        let categories = categoriesServise.categories
        
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
            tableViewContainer.frame.size.height = newHeight + 40
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoriesServise.categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        
        cell.textLabel?.text = categoriesServise.categories[indexPath.row]
      
        cell.tag = indexPath.row
        
        let interaction = UIContextMenuInteraction(delegate: self)
        cell.addInteraction(interaction)
        
        cell.backgroundColor = .gr
        cell.selectionStyle = .none
       
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if let selectedCell = tableView.cellForRow(at: indexPath) {
            if selectedCell == currentSelectedCell {

                selectedCell.accessoryType = .none
                currentSelectedCell = nil
            } else {

                currentSelectedCell?.accessoryType = .none
                
                currentSelectedCell = selectedCell
                currentSelectedCell?.accessoryType = .checkmark
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    @objc func didTapaddCategoryButton() {
        
        if currentSelectedCell?.accessoryType == .checkmark {
            dismiss(animated: true)
        } else {
            let createCategoriesController = CreateCategoriesController()
            
            createCategoriesController.modalPresentationStyle = .automatic
            present(createCategoriesController, animated: true, completion: nil)
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
                editCategoriesController.categoriesName = self.categoriesServise.categories[index]
                editCategoriesController.modalPresentationStyle = .automatic
                self.present(editCategoriesController, animated: true, completion: nil)
            }
            
            let deleteAction = UIAction(title: "Удалить", attributes: .destructive) { _ in
                            self.showDeleteConfirmation(for: index)
                        }
                        
                        return UIMenu(title: "", children: [editAction, deleteAction])
                    }
                }
                
                private func showDeleteConfirmation(for index: Int) {
                    let alert = UIAlertController(title: "",
                                                  message: "Эта категория точно не нужна?",
                                                  preferredStyle: .actionSheet)
                    
                    let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
                    let deleteAction = UIAlertAction(title: "Удалить", style: .destructive) { _ in
                        self.categoriesServise.categories.remove(at: index)
                        self.tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                        self.categoriesServise.saveCategories()
                    }
                    
                    alert.addAction(cancelAction)
                    alert.addAction(deleteAction)
                    
                    present(alert, animated: true, completion: nil)
                }
            }
