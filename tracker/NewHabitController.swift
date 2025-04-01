// NewIrregularEventController.swift
// tracker
//
// Created by Anastasiia on 26.02.2025.
//

import UIKit

final class NewHabitController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, ScheduleControllerDelegate {
    
    private var selectedWeekdays: [Weekday] = []
    
    func didSelectSchedule(_ days: [Weekday]) {
        print("Метод didSelectSchedule вызывается с днями:", days)
        
        selectedWeekdays = days
        
        let allWeekdays: [Weekday] = [.Monday, .Tuesday, .Wednesday, .Thursday, .Friday, .Saturday, .Sunday]
        
        if Set(days) == Set(allWeekdays) {
            chuseScheduleLabel.text = "Все дни"
        } else {
            let shortNames = days.map { $0.shortName }.joined(separator: ", ")
            DispatchQueue.main.async {
                self.chuseScheduleLabel.text = shortNames
                self.view.layoutIfNeeded()
            }
            updateCreateButtonState()
        }
    }
    
    
    @objc private func openSchedule() {
        let scheduleVC = ScheduleController()
        scheduleVC.delegate = self
        present(scheduleVC, animated: true)
    }
    let chuseScheduleLabel = UILabel()
    let scheduleLabel = UILabel()
    let categoriesController = CategoriesController()
    let categories = UILabel()
    let chuseCategoriesNames = UILabel()
    let name = UITextField()
    private let clearButton = UIButton(type: .custom)
    private let tableView = UITableView()
    private var tableData = [["Категория"], ["Расписание"]]
    let categoriesServise = CategoriesServise.shared
    private var selectedEmojiIndex: IndexPath?
    private var selectedColorIndex: IndexPath?
    var selectedEmoji: String?
    var selectedColors: String?
    let createButton = UIButton(type: .system)
    let sceduleService = SceduleService.shared
    
    private let emogies = [ "🙂", "😻", "🌺", "🐶", "❤️", "😱", "😇", "😡", "🥶", "🤔", "🙌", "🍔", "🥦", "🏓", "🥇", "🎸", "🏝", "😪"]
    
    private let colors: [UIColor] = [
        .colorSelection1, .colorSelection2, .colorSelection3, .colorSelection4, .colorSelection5, .colorSelection6, .colorSelection7, .colorSelection8, .colorSelection9, .colorSelection10, .colorSelection11, .colorSelection12, .colorSelection13, .colorSelection14, .colorSelection15, .colorSelection16, .colorSelection17, .colorSelection18
    ]
    
    private var selectedColor: UIColor?
    
    private var emojiCollectionView: UICollectionView!
    private var colorCollectionView: UICollectionView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default
            .addObserver(
                forName: CategoriesServise.didChangeCategories,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else { return }
                
                chuseCategoriesNames.text = categoriesServise.selectedCategory
                self.updateCreateButtonState()
            }
        
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        tableData = [["\(categories.text ?? "Категория")"], ["Расписание"]]
        setupClearButton()
        name.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        view.backgroundColor = .white
        
        let NewIrregularEventLabel = UILabel()
        NewIrregularEventLabel.textColor = .black
        NewIrregularEventLabel.text = "Новая привычка"
        NewIrregularEventLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        NewIrregularEventLabel.textAlignment = .center
        NewIrregularEventLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(NewIrregularEventLabel)
        NewIrregularEventLabel.setContentHuggingPriority(.required, for: .vertical)
        NewIrregularEventLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        
        NSLayoutConstraint.activate([
            NewIrregularEventLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            NewIrregularEventLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 38)
        ])
        
        name.placeholder = "Введите название трекера"
        name.textColor = .black
        name.backgroundColor = .gr
        name.layer.cornerRadius = 16
        name.layer.masksToBounds = true
        name.delegate = self
        name.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        name.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(name)
        name.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 1))
        name.leftViewMode = .always
        
        NSLayoutConstraint.activate([
            name.widthAnchor.constraint(equalToConstant: 343),
            
            name.heightAnchor.constraint(equalToConstant: 75),
            name.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            name.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            name.topAnchor.constraint(equalTo: NewIrregularEventLabel.bottomAnchor, constant: 38)
        ])
        
        let emojiLabel = UILabel()
        emojiLabel.text = "Emoji"
        emojiLabel.textColor = .black
        emojiLabel.font = UIFont.systemFont(ofSize: 19, weight: .bold)
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(emojiLabel)
        emojiLabel.setContentHuggingPriority(.required, for: .vertical)
        emojiLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        
        NSLayoutConstraint.activate([
            emojiLabel.widthAnchor.constraint(equalToConstant: 52),
            emojiLabel.heightAnchor.constraint(equalToConstant: 18),
            emojiLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 28),
            emojiLabel.topAnchor.constraint(equalTo: name.bottomAnchor, constant: 206)
        ])
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.layer.cornerRadius = 16
        tableView.backgroundColor = .gr
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.reloadData()
        tableView.isScrollEnabled = false
        contentView.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.widthAnchor.constraint(equalToConstant: 343),
            tableView.heightAnchor.constraint(equalToConstant: CGFloat(tableData.flatMap { $0 }.count) * 75),
            tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            tableView.topAnchor.constraint(equalTo: name.bottomAnchor, constant: 20)
        ])
        
        categories.text = "Категория"
        categories.textColor = .clear
        categories.translatesAutoresizingMaskIntoConstraints = false
        tableView.addSubview(categories)
        
        NSLayoutConstraint.activate([
            categories.leadingAnchor.constraint(equalTo: tableView.leadingAnchor, constant: 16),
            categories.topAnchor.constraint(equalTo: tableView.topAnchor, constant: 27)
        ])
        
        chuseCategoriesNames.textColor = .gray
        chuseCategoriesNames.translatesAutoresizingMaskIntoConstraints = false
        tableView.addSubview(chuseCategoriesNames)
        
        NSLayoutConstraint.activate([
            chuseCategoriesNames.leadingAnchor.constraint(equalTo: tableView.leadingAnchor, constant: 20),
            chuseCategoriesNames.topAnchor.constraint(equalTo: categories.bottomAnchor, constant: 2)
        ])
        
        scheduleLabel.text = "Расписание"
        scheduleLabel.textColor = .clear
        scheduleLabel.translatesAutoresizingMaskIntoConstraints = false
        tableView.addSubview(scheduleLabel)
        
        NSLayoutConstraint.activate([
            scheduleLabel.leadingAnchor.constraint(equalTo: tableView.leadingAnchor, constant: 16),
            scheduleLabel.topAnchor.constraint(equalTo: categories.bottomAnchor, constant: 51)
        ])
        
        
        chuseScheduleLabel.textColor = .gray
        chuseScheduleLabel.translatesAutoresizingMaskIntoConstraints = false
        tableView.addSubview( chuseScheduleLabel)
        
        
        NSLayoutConstraint.activate([
            chuseScheduleLabel.leadingAnchor.constraint(equalTo: tableView.leadingAnchor, constant: 20),
            chuseScheduleLabel.topAnchor.constraint(equalTo: scheduleLabel.bottomAnchor, constant: 2)
        ])
        
        let emojiLayout = UICollectionViewFlowLayout()
        emojiLayout.scrollDirection = .vertical
        emojiLayout.itemSize = CGSize(width: 50, height: 50)
        emojiLayout.minimumLineSpacing = 10
        emojiLayout.minimumInteritemSpacing = 10
        
        emojiCollectionView = UICollectionView(frame: .zero, collectionViewLayout: emojiLayout)
        emojiCollectionView.backgroundColor = .clear
        emojiCollectionView.dataSource = self
        emojiCollectionView.delegate = self
        emojiCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "EmojiCell")
        emojiCollectionView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(emojiCollectionView)
        emojiCollectionView.setContentHuggingPriority(.required, for: .vertical)
        
        NSLayoutConstraint.activate([
            emojiCollectionView.topAnchor.constraint(equalTo: emojiLabel.bottomAnchor, constant: 20),
            emojiCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            emojiCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            emojiCollectionView.heightAnchor.constraint(equalToConstant: 450)
        ])
        
        let colorLayout = UICollectionViewFlowLayout()
        colorLayout.scrollDirection = .vertical
        colorLayout.minimumLineSpacing = 10
        colorLayout.minimumInteritemSpacing = 10
        
        colorCollectionView = UICollectionView(frame: .zero, collectionViewLayout: colorLayout)
        colorCollectionView.backgroundColor = .clear
        colorCollectionView.dataSource = self
        colorCollectionView.delegate = self
        colorCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "ColorCell")
        colorCollectionView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(colorCollectionView)
        
        NSLayoutConstraint.activate([
            colorCollectionView.topAnchor.constraint(equalTo: emojiLabel.bottomAnchor, constant: 262),
            colorCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            colorCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            colorCollectionView.heightAnchor.constraint(equalToConstant: 200)
        ])
        
        let color = UILabel()
        color.text = "Цвет"
        color.textColor = .black
        color.font = UIFont.systemFont(ofSize: 19, weight: .bold)
        color.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(color)
        
        NSLayoutConstraint.activate([
            color.widthAnchor.constraint(equalToConstant: 52),
            color.heightAnchor.constraint(equalToConstant: 18),
            color.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 28),
            color.topAnchor.constraint(equalTo: name.bottomAnchor, constant: 444)
        ])
        
        let cancellButton = UIButton(type: .system)
        cancellButton.setTitle("Отменить", for: .normal)
        cancellButton.setTitleColor(.button, for: .normal)
        cancellButton.backgroundColor = .white
        cancellButton.layer.borderWidth = 1
        cancellButton.layer.borderColor = UIColor.button.cgColor
        cancellButton.layer.cornerRadius = 16
        cancellButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(cancellButton)
        cancellButton.setContentCompressionResistancePriority(.required, for: .vertical)
        cancellButton.addTarget(self, action: #selector(didTapCancelButton), for: .touchUpInside)
        
        cancellButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        
        NSLayoutConstraint.activate([
            cancellButton.widthAnchor.constraint(equalToConstant: 166),
            cancellButton.heightAnchor.constraint(equalToConstant:60),
            cancellButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            cancellButton.topAnchor.constraint(equalTo: colorCollectionView.bottomAnchor, constant: 16),
            cancellButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
        ])
        
        createButton.setTitle("Создать", for: .normal)
        createButton.setTitleColor(.white, for: .normal)
        createButton.backgroundColor = .greyButton
        createButton.setContentCompressionResistancePriority(.required, for: .vertical)
        createButton.isEnabled = false
        
        
        createButton.layer.cornerRadius = 16
        createButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(createButton)
        createButton.addTarget(self, action: #selector(didTapCreateButton), for: .touchUpInside)
        
        createButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        
        NSLayoutConstraint.activate([
            createButton.widthAnchor.constraint(equalToConstant: 166),
            createButton.heightAnchor.constraint(equalToConstant:60),
            createButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            createButton.topAnchor.constraint(equalTo: colorCollectionView.bottomAnchor, constant: 16)
        ])
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
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
        updateCreateButtonState()
    }
    
    @objc private func clearTextField() {
        name.text = ""
        clearButton.isHidden = true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // Скрываем клавиатуру
        return true
    }
    func updateCreateButtonState() {
        let isFormValid = !(name.text?.isEmpty ?? true) &&
        !(chuseCategoriesNames.text?.isEmpty ?? true) &&
        !(chuseScheduleLabel.text?.isEmpty ?? true) &&
        selectedEmoji != nil &&
        selectedColor != nil
        
        if isFormValid {
            createButton.isEnabled = true
            createButton.backgroundColor = .black
        } else {
            createButton.isEnabled = false
            createButton.backgroundColor = .greyButton
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData[section].count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = tableData[indexPath.section][indexPath.row]
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.textColor = .black
        cell.backgroundColor = .gr
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedOption = tableData[indexPath.section][indexPath.row]
        
        if selectedOption == "Категория" {
            let categoriesController = CategoriesController()
            present(categoriesController, animated: true)
        } else if selectedOption == "Расписание" {
            let scheduleVC = ScheduleController()
            scheduleVC.delegate = self  // Назначаем делегата
            present(scheduleVC, animated: true)
            let scheduleController = ScheduleController()
            present(scheduleController, animated: true)
        }
    }
}

extension NewHabitController {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == emojiCollectionView {
            return emogies.count
        } else if collectionView == colorCollectionView {
            return colors.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == emojiCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmojiCell", for: indexPath)
            
            cell.contentView.subviews.forEach { $0.removeFromSuperview()}
            
            let label = UILabel()
            label.text = emogies[indexPath.item]
            label.textAlignment = .center
            label.font = .systemFont(ofSize: 32)
            label.frame = CGRect(x: 0, y: 0, width: 60, height: 60)
            label.translatesAutoresizingMaskIntoConstraints = false
            
            cell.contentView.addSubview(label)
            
            label.centerXAnchor.constraint(equalTo: cell.contentView.centerXAnchor
            ).isActive = true
            label.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor).isActive = true
            
            cell.contentView.addSubview(label)
            cell.contentView.layer.cornerRadius = 16
            cell.contentView.layer.masksToBounds = true
            
            if selectedEmojiIndex == indexPath {
                cell.contentView.backgroundColor = .forEmoji
            } else {
                cell.contentView.backgroundColor = .clear
            }
            return cell
        }
        
        if collectionView == colorCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorCell", for: indexPath)
            
            cell.contentView.subviews.forEach { $0.removeFromSuperview() }
            
            let color = colors[indexPath.item]
            
            let outerView = UIView()
            outerView.frame = CGRect(x: 0, y: 0, width: 52, height: 52)
            outerView.layer.cornerRadius = 8
            outerView.translatesAutoresizingMaskIntoConstraints = false
            outerView.backgroundColor = color
            cell.contentView.addSubview(outerView)
            
            // Белая полоска
            let middleView = UIView()
            middleView.frame = CGRect(x: 0, y: 0, width: 46, height: 46)
            middleView.layer.cornerRadius = 8
            middleView.alpha = 1
            middleView.backgroundColor = .white
            middleView.translatesAutoresizingMaskIntoConstraints = false
            cell.contentView.addSubview(middleView)
            
            // Внутренний цветной квадрат
            let innerView = UIView()
            innerView.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
            innerView.layer.cornerRadius = 8
            innerView.alpha = 1
            innerView.backgroundColor = color
            innerView.translatesAutoresizingMaskIntoConstraints = false
            cell.contentView.addSubview(innerView)
            
            NSLayoutConstraint.activate([
                outerView.centerXAnchor.constraint(equalTo: cell.contentView.centerXAnchor),
                outerView.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
                outerView.widthAnchor.constraint(equalToConstant: 52),
                outerView.heightAnchor.constraint(equalToConstant: 52),
                
                middleView.centerXAnchor.constraint(equalTo: outerView.centerXAnchor),
                middleView.centerYAnchor.constraint(equalTo: outerView.centerYAnchor),
                middleView.widthAnchor.constraint(equalToConstant: 46),
                middleView.heightAnchor.constraint(equalToConstant: 46),
                
                innerView.centerXAnchor.constraint(equalTo: middleView.centerXAnchor),
                innerView.centerYAnchor.constraint(equalTo: middleView.centerYAnchor),
                innerView.widthAnchor.constraint(equalToConstant: 40),
                innerView.heightAnchor.constraint(equalToConstant: 40)
            ])
            
            if selectedColorIndex == indexPath {
                outerView.alpha = 0.3
                selectedColors = colors[indexPath.item].toHex()
                updateCreateButtonState()
            } else {
                outerView.alpha = 0
            }
            
            return cell
        }
        
        return UICollectionViewCell()
    }
}

extension NewHabitController {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == colorCollectionView {
            if selectedColorIndex == indexPath {
                selectedColorIndex = nil
                selectedColor = nil
            } else {
                selectedColorIndex = indexPath
                selectedColor = colors[indexPath.item] // Сохраняем цвет в переменную
            }
        } else if collectionView == emojiCollectionView {
            if selectedEmojiIndex == indexPath {
                selectedEmojiIndex = nil
                selectedEmoji = nil
            } else {
                selectedEmojiIndex = indexPath
                selectedEmoji = emogies[indexPath.item] // Сохраняем эмодзи в переменную
            }
        }
        
        collectionView.reloadData()
        updateCreateButtonState()
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == colorCollectionView {
            let itemsPerRow: CGFloat = 6
            let spacing: CGFloat = 10
            let totalSpacing = (itemsPerRow - 1) * spacing
            let availableWidth = collectionView.bounds.width - totalSpacing
            let itemSize = floor(availableWidth / itemsPerRow)
            
            return CGSize(width: itemSize, height: itemSize)
        }
        
        if collectionView == emojiCollectionView {
            let itemsPerRow: CGFloat = 6
            let spacing: CGFloat = 10
            let totalSpacing = (itemsPerRow - 1) * spacing
            let availableWidth = collectionView.bounds.width - totalSpacing
            let itemSize = floor(availableWidth / itemsPerRow)
            
            return CGSize(width: itemSize, height: itemSize)
        }
        
        return CGSize(width: 52, height: 52)
    }
    
    @objc func didTapCancelButton() {
        dismiss(animated: true)
    }
    
    
    @objc func didTapCreateButton() {
        print("Кнопка 'Создать' нажата")
        
        let weekdayArray = sceduleService.selectedWeekdays.compactMap { Weekday(rawValue: $0.rawValue) }
        
        if weekdayArray.isEmpty {
            print("Ошибка: Не выбраны дни недели для календаря")
            return
        }
        
        guard let calendarData = try? JSONEncoder().encode(weekdayArray) else {
            print("Ошибка при кодировании календаря в Data")
            return
        }
        
        let context = PersistenceController.shared.context
        
        let isCompleted = false
        var category: TrackerCategoryCoreData? = nil
        
        if let categoryName = chuseCategoriesNames.text, !categoryName.isEmpty {
            category = CoreDataService.shared.fetchCategory(byName: categoryName, context: context)
            
            if category == nil {
                category = CoreDataService.shared.createCategory(name: categoryName, context: context)
            }
        }
        
        let newTrackerCoreData = TrackerCoreData(context: context)
        newTrackerCoreData.id = UUID()
        newTrackerCoreData.name = name.text ?? ""
        newTrackerCoreData.color = selectedColors
        newTrackerCoreData.emoji = selectedEmoji
        newTrackerCoreData.calendar = calendarData as NSData
        newTrackerCoreData.isCompleted = isCompleted
        
        if let category = category {
            newTrackerCoreData.category = category
        }
        
        do {
            try context.save()
            print("Трекер успешно сохранен в Core Data")
        } catch {
            print("Ошибка сохранения в Core Data: \(error)")
            return
        }
        
        var targetVC = presentingViewController
        while targetVC != nil {
            if let tabBarController = targetVC as? UITabBarController {
                for viewController in tabBarController.viewControllers ?? [] {
                    if let viewController = viewController as? ViewController {
                        
                        viewController.addTracker(forCategory: chuseCategoriesNames.text ?? "", trackerCoreData: newTrackerCoreData)
                        viewController.dismiss(animated: true, completion: {
                            self.dismiss(animated: true, completion: nil)
                        })
                        return
                    }
                }
            }
            targetVC = targetVC?.presentingViewController
        }
        
        print("Не удалось найти нужный ViewController")
        dismiss(animated: true)
    }
    
}

