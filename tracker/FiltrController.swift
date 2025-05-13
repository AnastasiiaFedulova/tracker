//
//  FiltrController.swift
//  tracker
//
//  Created by Anastasiia on 26.02.2025.
//
import UIKit

protocol FiltrControllerDelegate: AnyObject {
    func didSelectFilter(_ filter: TrackerFilter)
}

enum TrackerFilter: Int {
    case all = 0
    case today
    case completed
    case notCompleted
}

final class FiltrController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    weak var delegate: FiltrControllerDelegate?
    private let options = ["Все трекеры", "Трекеры на сегодня", "Завершённые", "Не завершённые"]
    private let tableView = UITableView()
    
    var onFilterSelected: ((TrackerFilter) -> Void)?
    
    private let selectedFilterKey = "SelectedFilterIndex"
    
    private var selectedIndex: Int {
        get {
            if UserDefaults.standard.object(forKey: selectedFilterKey) == nil {
                return 0
            } else {
                return UserDefaults.standard.integer(forKey: selectedFilterKey)
            }
        }
        set {
            UserDefaults.standard.set(newValue, forKey: selectedFilterKey)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupLabel()
        setupTableView()
    }
    
    private func setupLabel() {
        let titleLabel = UILabel()
        titleLabel.text = "Фильтры"
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = .black
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 38)
        ])
    }
    
    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.layer.cornerRadius = 16
        tableView.backgroundColor = .gr
        tableView.rowHeight = 75
        tableView.isScrollEnabled = false
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "DefaultCell")
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 80),
            tableView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            tableView.widthAnchor.constraint(equalToConstant: 343),
            tableView.heightAnchor.constraint(equalToConstant: 300)
        ])
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultCell", for: indexPath)
        
        cell.textLabel?.text = options[indexPath.row]
        cell.textLabel?.font = UIFont.systemFont(ofSize: 17)
        cell.textLabel?.textColor = .black
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        
        cell.accessoryType = (indexPath.row == selectedIndex) ? .checkmark : .none
        cell.tintColor = .blue
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        
        tableView.reloadData()
        
        if let selectedFilter = TrackerFilter(rawValue: indexPath.row) {
            delegate?.didSelectFilter(selectedFilter)
            onFilterSelected?(selectedFilter)
        }
        
        dismiss(animated: true)
    }
}

