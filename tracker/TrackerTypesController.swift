//
//  TrackerTypesController.swift
//  tracker
//
//  Created by Anastasiia on 26.02.2025.
//

import UIKit

final class TrackerTypesController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        let MakeTracker = UILabel()
        MakeTracker.textColor = .black
        MakeTracker.text = "Создание трекера"
        MakeTracker.font = .boldSystemFont(ofSize: 16)
        MakeTracker.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(MakeTracker)
        
        NSLayoutConstraint.activate([
            MakeTracker.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 114),
            MakeTracker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -112),
            MakeTracker.topAnchor.constraint(equalTo: view.topAnchor, constant: 38)
        ])
        
        let buttonHabit = UIButton(type: .system)
        buttonHabit.setTitle("Привычка", for: .normal)
        buttonHabit.setTitleColor(.white, for: .normal)
        buttonHabit.backgroundColor = .black
        buttonHabit.layer.cornerRadius = 16
        buttonHabit.translatesAutoresizingMaskIntoConstraints = false
        buttonHabit.addTarget(self, action: #selector(didTapHabitButton), for: .touchUpInside)
        
        view.addSubview(buttonHabit)
        
        NSLayoutConstraint.activate([
            buttonHabit.heightAnchor.constraint(equalToConstant: 60),
            buttonHabit.widthAnchor.constraint(equalToConstant: 335),
            buttonHabit.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonHabit.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            buttonHabit.topAnchor.constraint(equalTo: view.topAnchor, constant: 395)
        ])
        
        let buttonIrregularEvent = UIButton(type: .system)
        buttonIrregularEvent.setTitle("Нерегулярное событие", for: .normal)
        buttonIrregularEvent.setTitleColor(.white, for: .normal)
        buttonIrregularEvent.backgroundColor = .black
        buttonIrregularEvent.layer.cornerRadius = 16
        buttonIrregularEvent.translatesAutoresizingMaskIntoConstraints = false
        buttonIrregularEvent.addTarget(self, action: #selector(didTapIrregularEventButton), for: .touchUpInside)
        
        view.addSubview(buttonIrregularEvent)
        
        NSLayoutConstraint.activate([
            buttonIrregularEvent.heightAnchor.constraint(equalToConstant: 60),
            buttonIrregularEvent.widthAnchor.constraint(equalToConstant: 335),
            buttonIrregularEvent.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonIrregularEvent.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            buttonIrregularEvent.topAnchor.constraint(equalTo: buttonHabit.bottomAnchor, constant: 16)
        ])
    }
    
    @objc func didTapHabitButton() {
        print("Button tapped")
        let newHabitController = NewHabitController()
        newHabitController.modalPresentationStyle = .automatic
        present(newHabitController, animated: true, completion: nil)
    }
    
    @objc func didTapIrregularEventButton() {
        print("Button tapped")
        let newIrregularEventController = NewIrregularEventController()
        newIrregularEventController.modalPresentationStyle = .automatic
        present(newIrregularEventController, animated: true, completion: nil)
    }
}
