//
//  TrackerTypesController.swift
//  tracker
//
import UIKit

final class TrackerTypesController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        let makeTracker = UILabel()
        makeTracker.textColor = .black
        makeTracker.text = NSLocalizedString("trecerTipes.title", comment: "")
        makeTracker.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        makeTracker.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(makeTracker)
        
        NSLayoutConstraint.activate([
            makeTracker.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            makeTracker.topAnchor.constraint(equalTo: view.topAnchor, constant: 38)
        ])
        
        let buttonHabit = UIButton(type: .custom)
        buttonHabit.setTitle(NSLocalizedString("trecerTipes.habbitTitel", comment: ""), for: .normal)
        buttonHabit.setTitleColor(.white, for: .normal)
        buttonHabit.backgroundColor = .black
        buttonHabit.layer.cornerRadius = 16
        
        buttonHabit.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        
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
        buttonIrregularEvent.setTitle(NSLocalizedString("trecerTipes.irregularTitel", comment: ""), for: .normal)
        buttonIrregularEvent.setTitleColor(.white, for: .normal)
        buttonIrregularEvent.backgroundColor = .black
        buttonIrregularEvent.layer.cornerRadius = 16
        
        buttonIrregularEvent.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        
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
