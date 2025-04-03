//
//  ScheduleController.swift
//  tracker
//
//  Created by Anastasiia on 28.02.2025.
//

import UIKit

protocol ScheduleControllerDelegate: AnyObject {
    func didSelectSchedule(_ days: [Weekday])
}

final class ScheduleController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let sceduleService = SceduleService.shared
    
    weak var delegate: ScheduleControllerDelegate?
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableData[section].count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = tableData[indexPath.section][indexPath.row]
        cell.textLabel?.textColor = .black
        cell.backgroundColor = .gr
        
        let switcher = UISwitch()
        switcher.isOn = false
        switcher.addTarget(self, action: #selector(switchChanged(_:)), for: .valueChanged)
        
        cell.accessoryView = switcher
        
        return cell
    }
    
    private let tableView = UITableView()
    private let tableData = [["Понедельник"], ["Вторник"], ["Среда"], ["Четверг"], ["Пятница"], ["Суббота"], ["Воскресенье"]]
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        sceduleService.selectedWeekdays = []
        
        view.backgroundColor = .white
        
        let scheduleLabel = UILabel()
        
        scheduleLabel.textColor = .black
        scheduleLabel.text = "Расписание"
        scheduleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        scheduleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scheduleLabel)
        
        NSLayoutConstraint.activate([
            scheduleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            scheduleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 38)
        ])
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.layer.cornerRadius = 16
        tableView.backgroundColor = .gr
        
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            
            tableView.widthAnchor.constraint(equalToConstant: 343),
            tableView.heightAnchor.constraint(equalToConstant: CGFloat(tableData.flatMap{ $0 }.count) * 75),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            tableView.topAnchor.constraint(equalTo: scheduleLabel.bottomAnchor, constant: 30)
        ])
        
        let doneButton = UIButton(type: .system)
        doneButton.setTitle("Готово", for: .normal)
        doneButton.setTitleColor(.white, for: .normal)
        doneButton.backgroundColor = .black
        doneButton.layer.cornerRadius = 16
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        doneButton.addTarget(self, action: #selector(didTapDoneButton), for: .touchUpInside)
        
        doneButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        
        view.addSubview(doneButton)
        
        NSLayoutConstraint.activate([
            doneButton.heightAnchor.constraint(equalToConstant: 60),
            doneButton.widthAnchor.constraint(equalToConstant: 335),
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
        
    }
    
    internal func tableView(_ tableView: UITableView, heightForRowAt: IndexPath) -> CGFloat {
        return 75
    }
    
    @objc private func switchChanged(_ sender: UISwitch) {
        sender.onTintColor = sender.isOn ? .blue : nil
        
        if let cell = sender.superview as? UITableViewCell,
           let indexPath = tableView.indexPath(for: cell) {
            let day = tableData[indexPath.section][indexPath.row]
            
            if sender.isOn {
                if let weekday = Weekday(rawValue: day) {
                    sceduleService.selectedWeekdays.append(weekday)
                    print("Добавлен день: \(weekday), выбранные дни: \(sceduleService.selectedWeekdays)")
                }
            } else {
                if let weekday = Weekday(rawValue: day),
                   let index = sceduleService.selectedWeekdays.firstIndex(of: weekday) {
                    sceduleService.selectedWeekdays.remove(at: index)
                    print("Удалён день: \(weekday), выбранные дни: \(sceduleService.selectedWeekdays)")
                }
            }
        }
    }
    
    @objc private func didTapDoneButton() {
        let selectedWeekdays = sceduleService.selectedWeekdays.compactMap { Weekday(rawValue: $0.rawValue) }
        
        if let delegate = delegate {
            delegate.didSelectSchedule(selectedWeekdays)
        } else {
            print("Делегат не назначен")
        }
        dismiss(animated: true)
    }
}

