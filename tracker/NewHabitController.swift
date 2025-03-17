// NewIrregularEventController.swift
// tracker
//
// Created by Anastasiia on 26.02.2025.
//

import UIKit

final class NewHabitController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, ScheduleControllerDelegate {
    
    private var selectedWeekdays: [Weekday] = []
    
    func didSelectSchedule(_ days: [Weekday]) {
        selectedWeekdays = days
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
            }
        
        
        tableData = [["\(categories.text ?? "Категория")"], ["Расписание"]]
        setupClearButton()
        name.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.alwaysBounceVertical = true
        view.addSubview(scrollView)
        
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
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
            NewIrregularEventLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 68),
            NewIrregularEventLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -66),
            NewIrregularEventLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 38),
            NewIrregularEventLabel.widthAnchor.constraint(equalToConstant: 241),
            NewIrregularEventLabel.heightAnchor.constraint(equalToConstant: 22)
        ])
        
        name.placeholder = "Введите название трекера"
        name.borderStyle = .roundedRect
        name.textColor = .black
        name.backgroundColor = .gr
        name.layer.cornerRadius = 16
        name.layer.masksToBounds = true
        name.delegate = self
        name.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        name.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(name)
        
        
        NSLayoutConstraint.activate([
            name.widthAnchor.constraint(equalToConstant: 343),
            
            name.heightAnchor.constraint(equalToConstant: 75),
            name.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            name.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            name.topAnchor.constraint(equalTo: NewIrregularEventLabel.bottomAnchor, constant: 38)
        ])
        
        
        let emojiLabel = UILabel()
        emojiLabel.text = "Emoji"
        emojiLabel.textColor = .black
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(emojiLabel)
        emojiLabel.setContentHuggingPriority(.required, for: .vertical)
        emojiLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        
        NSLayoutConstraint.activate([
            emojiLabel.widthAnchor.constraint(equalToConstant: 52),
            emojiLabel.heightAnchor.constraint(equalToConstant: 18),
            emojiLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 28),
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
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.widthAnchor.constraint(equalToConstant: 343),
            tableView.heightAnchor.constraint(equalToConstant: CGFloat(tableData.flatMap { $0 }.count) * 75),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
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
            chuseCategoriesNames.leadingAnchor.constraint(equalTo: tableView.leadingAnchor, constant: 18),
            chuseCategoriesNames.topAnchor.constraint(equalTo: categories.bottomAnchor, constant: 2),
            
        ])
        
        scheduleLabel.text = "Расписание"
        scheduleLabel.textColor = .clear
        scheduleLabel.translatesAutoresizingMaskIntoConstraints = false
        tableView.addSubview(scheduleLabel)
        
        NSLayoutConstraint.activate([
            scheduleLabel.leadingAnchor.constraint(equalTo: tableView.leadingAnchor, constant: 16),
            scheduleLabel.topAnchor.constraint(equalTo: categories.bottomAnchor, constant: 51)
            
        ])
        
        chuseScheduleLabel.text = "fff"
        chuseScheduleLabel.textColor = .clear
        chuseScheduleLabel.translatesAutoresizingMaskIntoConstraints = false
        tableView.addSubview( chuseScheduleLabel)
        
        
        NSLayoutConstraint.activate([
            chuseScheduleLabel.leadingAnchor.constraint(equalTo: tableView.leadingAnchor, constant: 18),
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
        emojiLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        
        NSLayoutConstraint.activate([
            emojiCollectionView.topAnchor.constraint(equalTo: emojiLabel.bottomAnchor, constant: 20),
            emojiCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            emojiCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
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
            colorCollectionView.topAnchor.constraint(equalTo: emojiLabel.bottomAnchor, constant: 268),
            colorCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            colorCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            colorCollectionView.heightAnchor.constraint(equalToConstant: 160)
        ])
        
        let color = UILabel()
        color.text = "Цвет"
        color.textColor = .black
        
        color.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(color)
        
        NSLayoutConstraint.activate([
            color.widthAnchor.constraint(equalToConstant: 52),
            color.heightAnchor.constraint(equalToConstant: 18),
            color.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 28),
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
        
        NSLayoutConstraint.activate([
            cancellButton.widthAnchor.constraint(equalToConstant: 166),
            cancellButton.heightAnchor.constraint(equalToConstant:60),
            cancellButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            cancellButton.topAnchor.constraint(equalTo: colorCollectionView.bottomAnchor, constant: 30)
        ])
        
        let createButton = UIButton(type: .system)
        createButton.setTitle("Создать", for: .normal)
        createButton.setTitleColor(.white, for: .normal)
        createButton.backgroundColor = .greyButton
        createButton.setContentCompressionResistancePriority(.required, for: .vertical)
        
        createButton.layer.cornerRadius = 16
        createButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(createButton)
        createButton.addTarget(self, action: #selector(didTapCreateButton), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            createButton.widthAnchor.constraint(equalToConstant: 166),
            createButton.heightAnchor.constraint(equalToConstant:60),
            createButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            createButton.topAnchor.constraint(equalTo: colorCollectionView.bottomAnchor, constant: 30)
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
            contentView.heightAnchor.constraint(equalToConstant: 1000),
            contentView.bottomAnchor.constraint(equalTo: cancellButton.bottomAnchor, constant: 20),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
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
        textField.resignFirstResponder() // Скрываем клавиатуру
        return true
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
            let label = UILabel()
            label.text = emogies[indexPath.item]
            label.textAlignment = .center
            label.font = .systemFont(ofSize: 32)
            label.frame = CGRect(x: 0, y: 0, width: 60, height: 60)
            
            cell.contentView.subviews.forEach { $0.removeFromSuperview() }
            cell.contentView.addSubview(label)
            cell.contentView.layer.cornerRadius = 10
            cell.contentView.layer.masksToBounds = true
            
            return cell
        } else if collectionView == colorCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorCell", for: indexPath)
            cell.contentView.subviews.forEach { $0.removeFromSuperview() }
            cell.contentView.backgroundColor = colors[indexPath.item]
            cell.contentView.layer.cornerRadius = 10
            return cell
        }
        return UICollectionViewCell()
    }
}

extension NewHabitController {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == colorCollectionView {
            selectedColor = colors[indexPath.item]
            print("Выбран цвет: \(selectedColor!)")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == colorCollectionView {
            let itemsPerRow: CGFloat = 6
            let spacing: CGFloat = 10
            let totalSpacing = (itemsPerRow - 1) * spacing
            let itemWidth = (collectionView.frame.width - totalSpacing) / itemsPerRow
            return CGSize(width: itemWidth, height: 50)
        }
        return CGSize(width: 50, height: 50)
    }
    
    @objc func didTapCancelButton() {
        dismiss(animated: true)
    }
    
    @objc func didTapCreateButton() {
        
        
        let weekdayArray = sceduleService.selectedWeekdays.compactMap { Weekday(rawValue: $0.rawValue) }
        let newTracker = Tracker(id: UUID(), name: name.text ?? "", color: .green, emoji: "🌿", calendar: weekdayArray, date: nil)
        
        var targetVC = presentingViewController
        while targetVC != nil, !(targetVC is ViewController) {
            targetVC = targetVC?.presentingViewController
        }
        
        guard let viewController = targetVC as? ViewController else {
            return
        }
        
        viewController.addTracker(forCategory: chuseCategoriesNames.text ?? "", tracker: newTracker)
        
        viewController.dismiss(animated: true)
    }
}

