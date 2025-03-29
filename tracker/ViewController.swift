//
//  ViewController.swift
//  tracker
//
//  Created by Anastasiia on 26.02.2025.
//
import UIKit


final class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return visibleCategories[section].trakers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TrackerCell", for: indexPath) as! TrackerCell
        let tracker = visibleCategories[indexPath.section].trakers[indexPath.item]
        let categoryName = visibleCategories[indexPath.section].title
        cell.configure(with: tracker, categoryName: categoryName, controller: self)
        return cell
    }
    
    var completedTrackers: [UUID: [String]] = [:] {
        didSet {
            saveCompletedTrackers()
        }
    }
    
    private func saveCompletedTrackers() {
        let data = try? JSONEncoder().encode(completedTrackers)
        UserDefaults.standard.set(data, forKey: completedTrackersKey)
    }
    
    private func loadCompletedTrackers() {
        if let data = UserDefaults.standard.data(forKey: completedTrackersKey),
           let savedTrackers = try? JSONDecoder().decode([UUID: [String]].self, from: data) {
            completedTrackers = savedTrackers
        }
    }
    func doneTrackersCount(id: UUID) -> Int {
        return completedTrackers[id]?.count ?? 0
    }
    
    public func addcompletedTracker(id: UUID, isCompleted: Bool) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        let formattedDate = dateFormatter.string(from: currentData.date)
        
        if isCompleted {
            if completedTrackers[id] == nil {
                completedTrackers[id] = []
            }
            if !(completedTrackers[id]?.contains(formattedDate) ?? false) {
                completedTrackers[id]?.append(formattedDate)
            }
        } else {
            completedTrackers[id]?.removeAll { $0 == formattedDate }
        }
        print(completedTrackers)
        collectionView.reloadData()
    }
    
    private let completedTrackersKey = "completedTrackers"
    let currentData = UIDatePicker()
    let searchBar = UISearchTextField()
    var collectionView: UICollectionView! = nil
    let starImage = UIImageView(image: UIImage(named: "star"))
    let labelStar = UILabel()
    private var visibleCategories: [TrackerCategory] = []
    
    var trackers: [TrackerCoreData] = []
    
    private var trackerStore: TrackerStore!
    
    var categories: [TrackerCategory] = []
    {
        didSet {
            reloadCategories()
        }
    }
    
    init() {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 12, left: 16, bottom: 0, right: 16)
        
        let padding: CGFloat = 16
        let spacing: CGFloat = 9
        let totalSpacing = padding * 2 + spacing
        let itemWidth = (UIScreen.main.bounds.width - totalSpacing) / 2
        layout.itemSize = CGSize(width: itemWidth, height: 148)
        layout.itemSize = CGSize(width: (UIScreen.main.bounds.width - 16 * 2 - 9) / 2, height: 148)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(nibName: nil, bundle: nil)
        collectionView.collectionViewLayout = layout
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        
        let context = PersistenceController.shared.context
        super.viewDidLoad()
        loadTrackers()
        
        let trackerStore = TrackerStore(context: PersistenceController.shared.context)
        if let loadedTrackers = trackerStore.fetchTrackers() {
            self.trackers = loadedTrackers
        }
        
        collectionView.reloadData()
        
        view.backgroundColor = .white
        loadCompletedTrackers()
        setupCollectionView()
        updateEmptyState()
        
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        var buttonPlus: UIButton
        let plusImage = UIImage(named: "plus")
        buttonPlus = getButton(plusImage: plusImage!)
        buttonPlus.tintColor = .black
        buttonPlus.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(buttonPlus)
        
        NSLayoutConstraint.activate([
            buttonPlus.heightAnchor.constraint(equalToConstant: 19),
            buttonPlus.widthAnchor.constraint(equalToConstant: 18),
            buttonPlus.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 1),
            buttonPlus.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 18)
        ])
        
        let trekerLabel = UILabel()
        trekerLabel.textColor = .black
        trekerLabel.text = "Трекеры"
        trekerLabel.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        trekerLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(trekerLabel)
        
        NSLayoutConstraint.activate([
            trekerLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            trekerLabel.topAnchor.constraint(equalTo:  buttonPlus.bottomAnchor, constant: 8),
            trekerLabel.widthAnchor.constraint(equalToConstant: 254),
            trekerLabel.heightAnchor.constraint(equalToConstant: 42)
        ])
        
        collectionView.backgroundColor = .white
        
        searchBar.placeholder = "Поиск"
        
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(searchBar)
        
        NSLayoutConstraint.activate([
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            searchBar.topAnchor.constraint(equalTo: trekerLabel.bottomAnchor, constant: 7),
            searchBar.heightAnchor.constraint(equalToConstant: 36)
        ])
        
        starImage.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(starImage)
        
        NSLayoutConstraint.activate([
            starImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            starImage.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            starImage.widthAnchor.constraint(equalToConstant: 80),
            starImage.heightAnchor.constraint(equalToConstant: 80)
        ])
        
        labelStar.text = "Что будем отслеживать?"
        
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
        
        currentData.translatesAutoresizingMaskIntoConstraints = false
        currentData.datePickerMode = .date
        view.addSubview(currentData)
        
        currentData.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        
        NSLayoutConstraint.activate([
            currentData.leadingAnchor.constraint(equalTo: buttonPlus.leadingAnchor, constant: 245),
            currentData.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            currentData.centerYAnchor.constraint(equalTo: buttonPlus.centerYAnchor)
        ])
        
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 34),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        reloadCategories()
    }
    
    @objc func dateChanged() {
        reloadCategories()
    }
    
    private func reloadCategories() {
        let calendar = Calendar.current
        let filterWeekday = calendar.component(.weekday, from: currentData.date) - 1
        let currentDate = currentData.date
        print("Текущая дата для фильтрации: \(currentDate)")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let currentDate2 = dateFormatter.string(from: currentData.date)
        visibleCategories = categories.map { category in
            TrackerCategory(
                title: category.title,
                trakers: category.trakers.filter { tracker in
                   // print("Проверяем трекер: \(tracker.name)")
                   // print("Явная дата трекера: \(String(describing: tracker.date))")

                    if let trackerDateString = tracker.date {
                     //   print("Явная дата трекера: \(trackerDateString)")
                        
                        return trackerDateString == currentDate2
                    }

                    if tracker.calendar.isEmpty {
                      //  print("Нет даты и пустой календарь, исключаем.")
                        return false
                    }
                    
                    let isDayOfWeek = tracker.calendar.contains { weekDay in
                        Weekday.allCases.firstIndex(of: weekDay) == filterWeekday
                    }
                   // print("Привязан к дню недели? \(isDayOfWeek)")
                    return isDayOfWeek
                }
            )
        }
        
        visibleCategories = visibleCategories.filter { !$0.trakers.isEmpty }
       // print("После фильтрации: \(visibleCategories.count) категорий, \(visibleCategories.flatMap { $0.trakers }.count) трекеров")
        
        collectionView.reloadData()
        updateEmptyState()
    }
    
    private func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    private func updateEmptyState() {
        let isEmpty = visibleCategories.isEmpty
        starImage.isHidden = !isEmpty
        labelStar.isHidden = !isEmpty
        collectionView.isHidden = isEmpty
    }
    
    private func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(TrackerCell.self, forCellWithReuseIdentifier: "TrackerCell")
        collectionView.register(CategoryHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CategoryHeaderView.reuseIdentifier)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 50)
    }
    
    func getButton(plusImage: UIImage) -> UIButton {
        return UIButton.systemButton(
            with: plusImage,
            target: self,
            action: #selector(didTapButton)
        )
    }
    
    @objc func didTapButton() {
        let trackerTypesController = TrackerTypesController()
        trackerTypesController.modalPresentationStyle = .automatic
        present(trackerTypesController, animated: true, completion: nil)
        //        let context = PersistenceController.shared.context
        //
        //         // Создаем запрос на получение всех трекеров
        //         let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        //
        //         do {
        //             // Выполняем запрос для получения всех трекеров
        //             let trackers = try context.fetch(fetchRequest)
        //
        //             // Удаляем каждый трекер из контекста
        //             for tracker in trackers {
        //                 context.delete(tracker)
        //             }
        //
        //             // Сохраняем контекст, чтобы изменения были внесены в Core Data
        //             try context.save()
        //             print("Все трекеры успешно удалены из Core Data.")
        //
        //         } catch {
        //             print("Ошибка при удалении трекеров: \(error)")
        //         }
    }
}

extension ViewController {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return visibleCategories.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "CategoryHeaderView", for: indexPath) as! CategoryHeaderView
        header.configure(with: visibleCategories[indexPath.section].title)
        return header
    }
    
    func loadTrackers() {
        var trackers = TrackerStore.shared.fetchTrackers()
        self.trackers = trackers ?? []
        updateCategoriesFromCoreData()
        collectionView.reloadData()
    }
}

extension ViewController {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let availableWidth = collectionView.bounds.width
        
        let padding: CGFloat = 16
        let spasing: CGFloat = availableWidth - (167 * 2) - (padding * 2)
        
        let numberOfItemsInRow: CGFloat = 2
        
        let itemWidth = (availableWidth - (padding * 2) - spasing) / numberOfItemsInRow
        
        return CGSize(width: itemWidth, height: 148)
    }
    
    func addTracker(forCategory categoryTitle: String, trackerCoreData: TrackerCoreData) {
        print("Добавляем трекер в категорию через Core Data")
        
        let context = PersistenceController.shared.context
        let categoryStore = TrackerCategoryStore(context: context)

        let category: TrackerCategoryCoreData
        if let existingCategory = categoryStore.fetchCategory(byTitle: categoryTitle) {
            category = existingCategory
        } else {
            category = TrackerCategoryCoreData(context: context)
            category.title = categoryTitle
            category.trackers = NSSet()
        }

        category.addToTrackers(trackerCoreData)

        do {
            try context.save()
            print("Категория и трекер обновлены в Core Data")
            updateCategoriesFromCoreData()
            collectionView.reloadData()
        } catch {
            print("Ошибка сохранения в Core Data: \(error)")
        }

        updateCategoriesFromCoreData()
    }
    
    
    func updateCategoriesFromCoreData() {
        
        do {
            let fetchedCategories = TrackerCategoryStore.shared.fetchCategories()
            
            categories = fetchedCategories.map { category in

                let trackers: [Tracker] = (category.trackers as? Set<TrackerCoreData>)?.compactMap { coreDataTracker in
                    guard let id = coreDataTracker.id else {

                        print("Трекер без id пропускаем")
                        return nil
                    }
                    
                    let name = coreDataTracker.name ?? "Без названия"
                    let emoji = coreDataTracker.emoji ?? "❓"
                    let calendarData = coreDataTracker.calendar as? Data
                    let calendar = decodeCalendar(from: calendarData)
                    
                    return Tracker(
                        id: id,
                        name: name,
                        color: .colorSelection5,
                        emoji: emoji,
                        calendar: calendar,
                        date: coreDataTracker.date
                    )
                } ?? []
                
                let title = category.title ?? "Без категории"  
                return TrackerCategory(title: title, trakers: trackers)
            }
        } catch {
            print("Ошибка загрузки категорий из Core Data: \(error)")
        }
    }
    
    
    func decodeCalendar(from data: Data?) -> [Weekday] {
        guard let data = data else { return [] }
        do {
            return try JSONDecoder().decode([Weekday].self, from: data)
        } catch {
            print("Ошибка декодирования календаря: \(error)")
            return []
        }
    }
}


final class TrackerCell: UICollectionViewCell {
    private let emojiLabel = UILabel()
    private let titleLabel = UILabel()
    private let background = UIView()
    private let emojiBackground = UIView()
    private let doneButton = UIButton()
    private let dayLabel = UILabel()
    
    
    var isCompleted = false
    var id: UUID? = nil
    var controller: ViewController
    
    override init(frame: CGRect) {
        self.controller = ViewController()
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.heightAnchor.constraint(equalToConstant: 148).isActive = true
        contentView.widthAnchor.constraint(equalToConstant: 167).isActive = true
        
        background.layer.cornerRadius = 16
        background.backgroundColor = .colorSelection5
        background.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(background)
        
        emojiBackground.layer.cornerRadius = 12
        emojiBackground.layer.masksToBounds = true
        emojiBackground.backgroundColor = .fone
        emojiBackground.translatesAutoresizingMaskIntoConstraints = false
        
        emojiLabel.font = .systemFont(ofSize: 16)
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        titleLabel.textColor = .white
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        dayLabel.text = "0 дней"
        dayLabel.textColor = .black
        dayLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        dayLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let image = UIImage(named: "Property1")?.withRenderingMode(.alwaysTemplate)
        doneButton.setImage(image, for: .normal)
        doneButton.tintColor = .colorSelection5
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        doneButton.addTarget(self, action: #selector(toggleCompletion), for: .touchUpInside)
        
        doneButton.layer.cornerRadius = 17
        doneButton.clipsToBounds = false
        doneButton.isUserInteractionEnabled = true
        
        background.addSubview(emojiBackground)
        background.addSubview(emojiLabel)
        background.addSubview(titleLabel)
        
        
        contentView.addSubview(dayLabel)
        contentView.addSubview(doneButton)
        
        NSLayoutConstraint.activate([
            
            
            background.topAnchor.constraint(equalTo: contentView.topAnchor, constant: -12),
            
            background.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            background.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            background.heightAnchor.constraint(equalToConstant: 90),
            background.widthAnchor.constraint(equalToConstant: 167),
            
            emojiBackground.widthAnchor.constraint(equalToConstant: 24),
            emojiBackground.heightAnchor.constraint(equalToConstant: 24),
            emojiBackground.topAnchor.constraint(equalTo: background.topAnchor, constant: 8),
            emojiBackground.leadingAnchor.constraint(equalTo: background.leadingAnchor, constant: 8),
            
            emojiLabel.centerXAnchor.constraint(equalTo: emojiBackground.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: emojiBackground.centerYAnchor),
            
            titleLabel.bottomAnchor.constraint(equalTo: background.bottomAnchor, constant: -8),
            titleLabel.leadingAnchor.constraint(equalTo: background.leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: background.trailingAnchor, constant: -8),
            
            dayLabel.topAnchor.constraint(equalTo: background.bottomAnchor, constant: 16),
            dayLabel.leadingAnchor.constraint(equalTo: background.leadingAnchor, constant: 12),
            
            doneButton.widthAnchor.constraint(equalToConstant: 34),
            doneButton.heightAnchor.constraint(equalToConstant: 34),
            doneButton.topAnchor.constraint(equalTo: background.bottomAnchor, constant: 8),
            doneButton.trailingAnchor.constraint(equalTo: background.trailingAnchor, constant: -12)
        ])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        print("Subviews:", contentView.subviews)
    }
    
    @objc private func toggleCompletion() {
        updateButtonState()
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        let formattedCurrentDate = dateFormatter.string(from: currentDate)
        
        let formattedTrackerDate = dateFormatter.string(from: controller.currentData.date)
        
        if formattedCurrentDate < formattedTrackerDate {
            return
        }
        
        if formattedTrackerDate <= formattedCurrentDate {
            
            isCompleted.toggle()
            let config = UIImage.SymbolConfiguration(pointSize: 35, weight: .black)
            
            let newImage = isCompleted
            ? UIImage(systemName: "checkmark.circle.fill", withConfiguration: config)?.withRenderingMode(.alwaysTemplate)
            : UIImage(named: "Property1")?.withRenderingMode(.alwaysTemplate)
            
            controller.addcompletedTracker(id: id!, isCompleted: isCompleted)
            updateButtonState()
            
            doneButton.setImage(nil, for: .normal)
            doneButton.setImage(newImage, for: .normal)
            
            doneButton.tintColor = .colorSelection5
            doneButton.alpha = isCompleted ? 0.3 : 1.0
            doneButton.layoutIfNeeded()
            
            controller.addcompletedTracker(id: id!, isCompleted: isCompleted)
            print("Кнопка нажата")
        } else {
            doneButton.isHidden = false
        }
    }
    
    func dayTipes(day: Int) -> String {
        let preLastDigit = (day / 10) % 10
        let lastDigit = day % 10
        
        if preLastDigit == 1 {
            return "\(day) дней"
        }
        
        switch lastDigit {
        case 1:
            return "\(day) день"
        case 2, 3, 4:
            return "\(day) дня"
        default:
            return "\(day) дней"
        }
    }
    
    func configure(with tracker: Tracker, categoryName: String, controller: ViewController) {
        updateButtonState()
        self.id = tracker.id
        self.controller = controller
        titleLabel.text = tracker.name
        emojiLabel.text = tracker.emoji
        background.backgroundColor = tracker.color
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        let formattedDate = dateFormatter.string(from: controller.currentData.date)
        
        isCompleted = controller.completedTrackers[tracker.id]?.contains(formattedDate) ?? false
        updateButtonState()
        
        let count = controller.doneTrackersCount(id: tracker.id)
        dayLabel.text = dayTipes(day: count)
    }
    
    private func updateButtonState() {
        let config = UIImage.SymbolConfiguration(pointSize: 35, weight: .black)
        let newImage = isCompleted
        ? UIImage(systemName: "checkmark.circle.fill", withConfiguration: config)?.withRenderingMode(.alwaysTemplate)
        : UIImage(named: "Property1")?.withRenderingMode(.alwaysTemplate)
        doneButton.setImage(newImage, for: .normal)
        
        doneButton.alpha = isCompleted ? 0.3 : 1.0
    }
}

final class CategoryHeaderView: UICollectionReusableView {
    static let reuseIdentifier = "CategoryHeaderView"
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 19, weight: .bold)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 28),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
    }
    
    func configure(with title: String) {
        titleLabel.text = title
    }
}



