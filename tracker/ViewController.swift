//
//  ViewController.swift
//  tracker
//
//  Created by Anastasiia on 26.02.2025.
//
import UIKit

final class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
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
        trekerLabel.font = .boldSystemFont(ofSize: 34)
        trekerLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(trekerLabel)
        
        NSLayoutConstraint.activate([
            trekerLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            trekerLabel.topAnchor.constraint(equalTo:  buttonPlus.bottomAnchor, constant: 8),
            trekerLabel.widthAnchor.constraint(equalToConstant: 254),
            trekerLabel.heightAnchor.constraint(equalToConstant: 42)
        ])
        
        let searchBar = UISearchBar()
        searchBar.placeholder = "Поиск"
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.setBackgroundImage(UIImage.init(), for: UIBarPosition.any, barMetrics: UIBarMetrics.default)
        view.addSubview(searchBar)
        
        NSLayoutConstraint.activate([
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            searchBar.topAnchor.constraint(equalTo: trekerLabel.bottomAnchor, constant: 7),
            searchBar.widthAnchor.constraint(equalToConstant: 343),
            searchBar.heightAnchor.constraint(equalToConstant: 36)
        ])
        
        let starImage = UIImageView(image: UIImage(named: "star"))
        starImage.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(starImage)
        
        NSLayoutConstraint.activate([
            starImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            starImage.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            starImage.widthAnchor.constraint(equalToConstant: 80),
            starImage.heightAnchor.constraint(equalToConstant: 80)
        ])
        
        let tabBarController = UITabBarController()
        
        let firstViewController = UIViewController()
        firstViewController.tabBarItem = UITabBarItem(
            title: "Трекеры",
            image: UIImage(named: "ic 28x28 1"),
            selectedImage: UIImage(named: "ic 28x28 1")
        )
        
        let secondViewController = UIViewController()
        secondViewController.tabBarItem = UITabBarItem(
            title: "Профиль",
            image: UIImage(named: "ic 28x28 2"),
            selectedImage: UIImage(named: "ic 28x28 3")
        )
        
        tabBarController.viewControllers = [firstViewController, secondViewController]
        
        addChild(tabBarController)
        view.addSubview(tabBarController.view)
        tabBarController.didMove(toParent: self)
        
        tabBarController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tabBarController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tabBarController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tabBarController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tabBarController.view.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 8)
        ])
        
        let labelStar = UILabel()
        labelStar.text = "Что будем отслеживать?"
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
        
        let currentData = UIDatePicker()
        currentData.translatesAutoresizingMaskIntoConstraints = false
        currentData.datePickerMode = .date
        view.addSubview(currentData)
        
        NSLayoutConstraint.activate([
            currentData.leadingAnchor.constraint(equalTo: buttonPlus.leadingAnchor, constant: 245),
            currentData.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            currentData.centerYAnchor.constraint(equalTo: buttonPlus.centerYAnchor)
        ])
        
    }
    func getButton(plusImage: UIImage) -> UIButton {
        return UIButton.systemButton(
            with: plusImage,
            target: self,
            action: #selector(didTapButton)
        )
    }
    
    @objc func didTapButton() {
        print("Button tapped")
        let trackerTypesController = TrackerTypesController()
        trackerTypesController.modalPresentationStyle = .automatic
        present(trackerTypesController, animated: true, completion: nil)
        
    }
}
