//  ViewController.swift
//  tracker
//
//  Created by Anastasiia on 26.02.2025.
//
import UIKit

final class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UITextFieldDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return visibleCategories[section].trakers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TrackerCell", for: indexPath) as! TrackerCell
        let tracker = visibleCategories[indexPath.section].trakers[indexPath.item]
        let categoryName = visibleCategories[indexPath.section].title
        cell.configure(with: tracker, categoryName: categoryName, controller: self)
        let context = PersistenceController.shared.context
        let isPinned = CoreDataService.shared.fetchTracker(byID: tracker.id, context: context)?.isPinned ?? false
        cell.pinImageView.isHidden = !isPinned
        return cell
    }
    
    var completedTrackers: [UUID: [String]] = [:] {
        didSet {
            saveCompletedTrackers()
            NotificationCenter.default.post(
                name: .completedTrackersUpdated,
                object: nil,
                userInfo: ["data": completedTrackers]
            )
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
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        AnalyticsService.shared.sendEvent(event: "open", screen: "Main")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        AnalyticsService.shared.sendEvent(event: "close", screen: "Main")
    }
    
    private let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Отменить", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        button.tintColor = .filterBlue
        button.isHidden = true
        return button
    }()
    
    private let notFindTrecker: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "notFind")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isHidden = true
        return imageView
    }()
    
    private let notFindLabel: UILabel = {
        let label = UILabel()
        label.text = "Ничего не найдено"
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .forText
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        return label
    }()
    
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
    var searchBarTrailingConstraint: NSLayoutConstraint!
    private var currentFilter: TrackerFilter = .all
    private let colors = Colors()
    
    private var currentWeekday: Weekday {
        let weekdayNumber = Calendar.current.component(.weekday, from: currentData.date)
        return Weekday(calendarWeekday: weekdayNumber)!
    }
    
    private var searchText: String = "" {
        didSet {
            reloadCategories()
        }
    }
    
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
        super.viewDidLoad()
        view.backgroundColor = colors.viewBackgroundColor
        
        trackerStore = TrackerStore(context: PersistenceController.shared.context)
        
        trackerStore.onUpdate = { [weak self] in
            guard let self else { return }
            DispatchQueue.main.async {
                
                self.updateCategoriesFromCoreData()
                self.updateVisibleCategories()
            }
        }
        
        loadCompletedTrackers()
        
        trackers = trackerStore.getTrackers()
        updateCategoriesFromCoreData()
        
        updateVisibleCategories()
        
        setupCollectionView()
        updateEmptyState()
        collectionView.reloadData()
        
        let context = PersistenceController.shared.context
        
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        var buttonPlus: UIButton
        let plusImage = UIImage(named: "plus")
        buttonPlus = getButton(plusImage: plusImage!)
        buttonPlus.tintColor = colors.labelColor
        buttonPlus.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(buttonPlus)
        
        NSLayoutConstraint.activate([
            buttonPlus.heightAnchor.constraint(equalToConstant: 19),
            buttonPlus.widthAnchor.constraint(equalToConstant: 18),
            buttonPlus.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 1),
            buttonPlus.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 18)
        ])
        
        let trekerLabel = UILabel()
        trekerLabel.textColor = colors.labelColor
        trekerLabel.text = NSLocalizedString("trecers.title", comment: "")
        trekerLabel.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        trekerLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(trekerLabel)
        
        NSLayoutConstraint.activate([
            trekerLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            trekerLabel.topAnchor.constraint(equalTo: buttonPlus.bottomAnchor, constant: 8),
            trekerLabel.widthAnchor.constraint(equalToConstant: 254),
            trekerLabel.heightAnchor.constraint(equalToConstant: 42)
        ])
        
        searchBar.placeholder = NSLocalizedString("trecers.findTitle", comment: "")
        searchBar.delegate = self
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBarTrailingConstraint = searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        
        searchBar.textColor = colors.labelColor
        searchBar.attributedPlaceholder = NSAttributedString(
            string: NSLocalizedString("trecers.findTitle", comment: ""),
            attributes: [.foregroundColor: colors.labelColor.withAlphaComponent(0.6)]
        )
        
        view.addSubview(searchBar)
        
        NSLayoutConstraint.activate([
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchBarTrailingConstraint,
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
        
        collectionView.backgroundColor = colors.viewBackgroundColor
        
        let filtr = UIButton()
        filtr.backgroundColor = .filterBlue
        filtr.setTitle(NSLocalizedString("filtrs", comment: ""), for: .normal)
        filtr.layer.cornerRadius = 16
        filtr.translatesAutoresizingMaskIntoConstraints = false
        collectionView.addSubview(filtr)
        filtr.setContentCompressionResistancePriority(.required, for: .vertical)
        filtr.addTarget(self, action: #selector(didTapFiltr), for: .touchUpInside)
        
        filtr.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        
        NSLayoutConstraint.activate([
            filtr.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            filtr.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filtr.heightAnchor.constraint(equalToConstant: 50),
            filtr.widthAnchor.constraint(equalToConstant: 120)
        ])
        
        view.addSubview(cancelButton)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.addTarget(self, action: #selector(stopFind), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            cancelButton.leadingAnchor.constraint(equalTo: searchBar.trailingAnchor, constant: 5),
            cancelButton.centerYAnchor.constraint(equalTo: searchBar.centerYAnchor)
        ])
        
        labelStar.text = NSLocalizedString("trecers.starTitle", comment: "")
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
        currentData.preferredDatePickerStyle = .compact
        currentData.locale = Locale(identifier: "ru_RU")
        
        let whiteBackground = UIView()
        whiteBackground.translatesAutoresizingMaskIntoConstraints = false
        whiteBackground.backgroundColor = .white
        whiteBackground.layer.cornerRadius = 8
        whiteBackground.layer.masksToBounds = true
        
        view.addSubview(whiteBackground)
        view.addSubview(currentData)
        
        currentData.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        
        if #available(iOS 13.0, *) {
            currentData.overrideUserInterfaceStyle = .light
        }
        
        NSLayoutConstraint.activate([
            whiteBackground.widthAnchor.constraint(equalTo: currentData.widthAnchor),
            whiteBackground.heightAnchor.constraint(equalTo: currentData.heightAnchor),
            whiteBackground.centerXAnchor.constraint(equalTo: currentData.centerXAnchor),
            whiteBackground.centerYAnchor.constraint(equalTo: currentData.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            currentData.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            currentData.centerYAnchor.constraint(equalTo: buttonPlus.centerYAnchor)
        ])
        
        view.addSubview(notFindTrecker)
        view.addSubview(notFindLabel)
        
        NSLayoutConstraint.activate([
            notFindTrecker.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            notFindTrecker.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            notFindTrecker.widthAnchor.constraint(equalToConstant: 80),
            notFindTrecker.heightAnchor.constraint(equalToConstant: 80),
            
            notFindLabel.topAnchor.constraint(equalTo: notFindTrecker.bottomAnchor, constant: 8),
            notFindLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
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
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        cancelButton.isHidden = false
        searchBarTrailingConstraint.constant = -104
        UIView.animate(withDuration: 0.1) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func dateChanged() {
        updateVisibleCategories()
    }
    
    @objc func stopFind() {
        cancelButton.isHidden = true
        searchBarTrailingConstraint.constant = -16
    }
    
    @objc func reloadData() {
        self.trackers = trackerStore.getTrackers()
        collectionView.reloadData()
    }
    
    private func reloadCategories() {
        updateVisibleCategories()
    }
    
    
    internal func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    private func updateEmptyState() {
        let isSearching = !searchText.trimmingCharacters(in: .whitespaces).isEmpty
        let noResults = visibleCategories.isEmpty
        
        if isSearching && noResults {
            notFindTrecker.isHidden = false
            notFindLabel.isHidden = false
            
            starImage.isHidden = true
            labelStar.isHidden = true
            collectionView.isHidden = true
        } else {
            let isEmpty = visibleCategories.isEmpty
            
            notFindTrecker.isHidden = true
            notFindLabel.isHidden = true
            
            starImage.isHidden = !isEmpty
            labelStar.isHidden = !isEmpty
            collectionView.isHidden = isEmpty
        }
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
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchText = searchText
        updateVisibleCategories()
    }
    
    @objc func didTapButton() {
        AnalyticsService.shared.sendEvent(event: "click", screen: "Main", item: "add_track")
        
        let trackerTypesController = TrackerTypesController()
        trackerTypesController.modalPresentationStyle = .automatic
        present(trackerTypesController, animated: true, completion: nil)
    }
    
    @objc func didTapFiltr() {
        AnalyticsService.shared.sendEvent(event: "click", screen: "Main", item: "filter")
        
        let filtrController = FiltrController()
        filtrController.delegate = self
        filtrController.modalPresentationStyle = .automatic
        present(filtrController, animated: true, completion: nil)
    }
}
extension ViewController: UISearchTextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text,
           let textRange = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: textRange, with: string)
            searchText = updatedText
        }
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        searchText = ""
        return true
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
        self.trackers = trackerStore.getTrackers()
        updateCategoriesFromCoreData()
        
        updateVisibleCategories()
        
        collectionView.reloadData()
    }
    
    private func updateVisibleCategories() {
        
        let calendar = Calendar.current
        let filterWeekday = calendar.component(.weekday, from: currentData.date) - 1
        let currentDate = currentData.date
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let currentDateString = dateFormatter.string(from: currentDate)
        
        var pinnedTrackers: [Tracker] = []
        var otherCategories: [TrackerCategory] = []
        
        for category in categories {
            var unpinnedTrackers: [Tracker] = []
            
            for tracker in category.trakers {
                
                var matchesDate = false
                if let trackerDate = tracker.date {
                    matchesDate = trackerDate == currentDateString
                } else if !tracker.calendar.isEmpty {
                    matchesDate = tracker.calendar.contains {
                        Weekday.allCases.firstIndex(of: $0) == filterWeekday
                    }
                }
                
                let matchesSearch = searchText.isEmpty || tracker.name.lowercased().contains(searchText.lowercased())
                
                var matchesFilter = true
                switch currentFilter {
                case .all:
                    matchesFilter = true
                    
                case .today:
                    matchesFilter = Calendar.current.isDate(currentDate, inSameDayAs: Date())
                    
                case .completed:
                    matchesFilter = completedTrackers[tracker.id]?.contains(where: {
                        guard let date = parseDate(from: $0) else { return false }
                        return Calendar.current.isDate(date, inSameDayAs: currentDate)
                    }) ?? false
                    
                case .notCompleted:
                    matchesFilter = !(completedTrackers[tracker.id]?.contains(where: {
                        guard let date = parseDate(from: $0) else { return false }
                        return Calendar.current.isDate(date, inSameDayAs: currentDate)
                    }) ?? false)
                }
                
                if !(matchesDate && matchesSearch && matchesFilter) {
                    continue
                }
                
                let context = PersistenceController.shared.context
                if let coreDataTracker = CoreDataService.shared.fetchTracker(byID: tracker.id, context: context),
                   coreDataTracker.isPinned {
                    pinnedTrackers.append(tracker)
                } else {
                    unpinnedTrackers.append(tracker)
                }
            }
            
            if !unpinnedTrackers.isEmpty {
                otherCategories.append(TrackerCategory(title: category.title, trakers:unpinnedTrackers))
            }
        }
        
        var updatedCategories: [TrackerCategory] = []
        
        if !pinnedTrackers.isEmpty {
            updatedCategories.append(TrackerCategory(title: "Закреплённые", trakers: pinnedTrackers))
        }
        
        updatedCategories.append(contentsOf: otherCategories)
        visibleCategories = updatedCategories
        
        collectionView.reloadData()
        updateEmptyState()
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
        
        if trackerCoreData.category == nil {
            category.addToTrackers(trackerCoreData)
        } else {
            print("ℹ️ Трекер уже привязан к категории: \(trackerCoreData.category?.title ?? "-")")
        }
        
        do {
            try context.save()
            updateCategoriesFromCoreData()
            updateVisibleCategories()
            
        } catch {
            print("Ошибка сохранения в Core Data: \(error)")
        }
    }
    
    func updateCategoriesFromCoreData() {
        do {
            let fetchedCategories = TrackerCategoryStore.shared.fetchCategories()
            
            var pinnedTrackers: [Tracker] = []
            var otherCategories: [TrackerCategory] = []
            
            for category in fetchedCategories {
                guard let categoryTitle = category.title else { continue }
                
                let trackers = (category.trackers as? Set<TrackerCoreData>)?.compactMap { coreDataTracker -> Tracker? in
                    guard let id = coreDataTracker.id,
                          let name = coreDataTracker.name,
                          let emoji = coreDataTracker.emoji,
                          let color = coreDataTracker.color else {
                        return nil
                    }
                    
                    let calendarData = coreDataTracker.calendar as? Data
                    let calendar = decodeCalendar(from: calendarData)
                    let tracker = Tracker(
                        id: id,
                        name: name,
                        color: UIColor.fromHex(hex: color),
                        emoji: emoji,
                        calendar: calendar,
                        date: coreDataTracker.date
                    )
                    
                    if coreDataTracker.isPinned {
                        pinnedTrackers.append(tracker)
                        return nil // не добавляем в обычную категорию
                    }
                    
                    return tracker
                } ?? []
                
                if !trackers.isEmpty {
                    otherCategories.append(TrackerCategory(title: categoryTitle, trakers: trackers))
                }
            }
            
            var result: [TrackerCategory] = []
            
            if !pinnedTrackers.isEmpty {
                result.append(TrackerCategory(title: "Закреплённые", trakers: pinnedTrackers))
            }
            
            result.append(contentsOf: otherCategories)
            
            self.categories = result
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

extension ViewController {
    func collectionView(_ collectionView: UICollectionView,
                        contextMenuConfigurationForItemAt indexPath: IndexPath,
                        point: CGPoint) -> UIContextMenuConfiguration? {
        
        let tracker = visibleCategories[indexPath.section].trakers[indexPath.item]
        let context = PersistenceController.shared.context
        let pinned = CoreDataService.shared.fetchTracker(byID: tracker.id, context: context)?.isPinned ?? false
        
        return UIContextMenuConfiguration(identifier: indexPath as NSCopying, previewProvider: nil) { _ in
            
            let pinText = pinned ? "Открепить" : "Закрепить"
            
            let saveAction = UIAction(title: pinText) { _ in
                guard let coreDataTracker = CoreDataService.shared.fetchTracker(byID: tracker.id, context: context) else {
                    print("Не найден TrackerCoreData с id \(tracker.id)")
                    return
                }
                coreDataTracker.isPinned.toggle()
                
                do {
                    try context.save()
                    print(coreDataTracker.isPinned ? "Закрепили \(tracker.id)" : "Открепили \(tracker.id)")
                    self.updateCategoriesFromCoreData()
                } catch {
                    print("Ошибка при обновлении isPinned: \(error)")
                }
            }
            
            let editAction = UIAction(title: "Редактировать") { _ in
                AnalyticsService.shared.sendEvent(event: "click", screen: "Main", item: "edit")
                
                guard let trackerToEdit = CoreDataService.shared.fetchTracker(byID: tracker.id, context: context) else {
                    print("Не удалось найти TrackerCoreData с id \(tracker.id)")
                    return
                }
                
                let scheduleText = tracker.calendar.map { $0.shortName }.joined(separator: ", ")
                let editHabbitController = EditHabbitController()
                editHabbitController.trackerToEdit = trackerToEdit
                editHabbitController.tracker = tracker
                editHabbitController.habbitText = tracker.name
                editHabbitController.sceduleText = scheduleText
                editHabbitController.categoyText = self.visibleCategories[indexPath.section].title
                editHabbitController.selectedEmoji = tracker.emoji
                editHabbitController.selectedColor = tracker.color
                
                if let cell = self.collectionView.cellForItem(at: indexPath) as? TrackerCell {
                    editHabbitController.dayText = cell.dayLabel.text
                }
                
                editHabbitController.modalPresentationStyle = .automatic
                self.present(editHabbitController, animated: true, completion: nil)
            }
            
            let deleteAction = UIAction(title: "Удалить", attributes: .destructive) { _ in
                AnalyticsService.shared.sendEvent(event: "click", screen: "Main", item: "delete")
                
                let alert = UIAlertController(
                    title: nil,
                    message: "Уверены что хотите удалить трекер?",
                    preferredStyle: .actionSheet
                )
                
                let confirm = UIAlertAction(title: "Удалить", style: .destructive) { _ in
                    do {
                        if let coreDataTracker = try? self.trackerStore.fetchTrackerCoreData(by: tracker.id) {
                            try self.trackerStore.deleteTracker(tracker: coreDataTracker)
                        }
                    } catch {
                        print("Ошибка при удалении трекера: \(error)")
                    }
                    
                    var updatedCategories = self.categories
                    if let categoryIndex = updatedCategories.firstIndex(where: { $0.title == self.visibleCategories[indexPath.section].title }) {
                        var trackers = updatedCategories[categoryIndex].trakers
                        trackers.removeAll { $0.id == tracker.id }
                        
                        if trackers.isEmpty {
                            updatedCategories.remove(at: categoryIndex)
                        } else {
                            updatedCategories[categoryIndex] = TrackerCategory(title: self.visibleCategories[indexPath.section].title, trakers: trackers)
                        }
                    }
                    
                    self.categories = updatedCategories
                    self.updateVisibleCategories()
                }
                
                let cancel = UIAlertAction(title: "Отменить", style: .cancel)
                
                alert.addAction(confirm)
                alert.addAction(cancel)
                self.present(alert, animated: true)
            }
            
            return UIMenu(title: "", children: [saveAction, editAction, deleteAction])
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        guard let indexPath = configuration.identifier as? IndexPath,
              let cell = collectionView.cellForItem(at: indexPath) as? TrackerCell else {
            return nil
        }
        
        let targetView = cell.background
        let parameters = UIPreviewParameters()
        parameters.visiblePath = UIBezierPath(roundedRect: targetView.bounds, cornerRadius: 16)
        parameters.backgroundColor = .clear
        
        return UITargetedPreview(view: targetView, parameters: parameters)
    }
    
    
    private func applyFilter() {
        let calendar = Calendar.current
        let currentDate = currentData.date
        let weekday = calendar.component(.weekday, from: currentDate)
        
        var pinnedTrackers: [Tracker] = []
        var otherCategories: [TrackerCategory] = []
        
        for category in categories {
            var unpinned: [Tracker] = []
            
            for tracker in category.trakers {
                let passesFilter: Bool = {
                    switch currentFilter {
                    case .all:
                        return true
                        
                    case .today:
                        return tracker.calendar.contains {
                            Weekday.allCases.firstIndex(of: $0) == weekday - 1
                        }
                        
                    case .completed:
                        return completedTrackers[tracker.id]?.contains(where: {
                            guard let date = parseDate(from: $0) else { return false }
                            return calendar.isDate(date, inSameDayAs: currentDate)
                        }) ?? false
                        
                    case .notCompleted:
                        return !(completedTrackers[tracker.id]?.contains(where: {
                            guard let date = parseDate(from: $0) else { return false }
                            return calendar.isDate(date, inSameDayAs: currentDate)
                        }) ?? false)
                    }
                }()
                
                if !passesFilter { continue }

                let context = PersistenceController.shared.context
                let isPinned = CoreDataService.shared.fetchTracker(byID: tracker.id, context: context)?.isPinned ?? false
                
                if isPinned {
                    pinnedTrackers.append(tracker)
                } else {
                    unpinned.append(tracker)
                }
            }
            
            if !unpinned.isEmpty {
                otherCategories.append(TrackerCategory(title: category.title, trakers: unpinned))
            }
        }
        
        var result: [TrackerCategory] = []
        
        if !pinnedTrackers.isEmpty {
            result.append(TrackerCategory(title: "Закреплённые", trakers: pinnedTrackers))
        }
        
        result.append(contentsOf: otherCategories)
        
        visibleCategories = result
        collectionView.reloadData()
        updateEmptyState()
    }
    
    
    func parseDate(from dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        return dateFormatter.date(from: dateString)
    }
    
    private func decodeWeekdays(from data: Data?) -> [Weekday] {
        guard let data = data else { return [] }
        return (try? JSONDecoder().decode([Weekday].self, from: data)) ?? []
    }
}

extension ViewController: FiltrControllerDelegate {
    func didSelectFilter(_ filter: TrackerFilter) {
        currentFilter = filter
        applyFilter()
    }
}

final class TrackerCell: UICollectionViewCell {
    private let emojiLabel = UILabel()
    private let titleLabel = UILabel()
    let background = UIView()
    private let emojiBackground = UIView()
    private let doneButton = UIButton()
    let dayLabel = UILabel()
    private let colors = Colors()
    
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
    let pinImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "pin"))
        imageView.tintColor = .white
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isHidden = false
        return imageView
    }()
    
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
        dayLabel.textColor = colors.labelColor
        dayLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        dayLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let image = UIImage(named: "Property1")?.withRenderingMode(.alwaysTemplate)
        doneButton.setImage(image, for: .normal)
        doneButton.tintColor = .clear
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
        
        background.addSubview(pinImageView)
        
        NSLayoutConstraint.activate([
            pinImageView.topAnchor.constraint(equalTo: background.topAnchor, constant: 18),
            pinImageView.trailingAnchor.constraint(equalTo: background.trailingAnchor, constant: -12),
            pinImageView.widthAnchor.constraint(equalToConstant: 8),
            pinImageView.heightAnchor.constraint(equalToConstant:12)
        ])
        
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
        AnalyticsService.shared.sendEvent(event: "click", screen: "Main", item: "track")
        
        let currentDate = Date()
        let trackerDate = controller.currentData.date
        
        let calendar = Calendar.current
        
        let currentDateOnly = calendar.startOfDay(for: currentDate)
        let trackerDateOnly = calendar.startOfDay(for: trackerDate)
        
        if trackerDateOnly > currentDateOnly {
            return
        }
        
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
        
        print("Кнопка нажата")
    }
    
    func dayTipes(day: Int) -> String {
        let format = NSLocalizedString("days.count", comment: "")
        return String.localizedStringWithFormat(format, day)
    }
    
    func configure(with tracker: Tracker, categoryName: String, controller: ViewController) {
        self.id = tracker.id
        self.controller = controller
        titleLabel.text = tracker.name
        emojiLabel.text = tracker.emoji
        background.backgroundColor = tracker.color
        doneButton.tintColor = tracker.color
        
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
    private let colors = Colors()
    
    static let reuseIdentifier = "CategoryHeaderView"
    
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 19, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        titleLabel.textColor = colors.labelColor
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
