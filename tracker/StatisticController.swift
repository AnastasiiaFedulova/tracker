//
//  StatisticController.swift
//  tracker
//
//  Created by Anastasiia on 17.04.2025.
//

import Foundation
import UIKit

final class StatisticController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let statisticLabel = UILabel()
        statisticLabel.textColor = .black
        statisticLabel.text = "Статистика"
        statisticLabel.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        statisticLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(statisticLabel)
        
        NSLayoutConstraint.activate([
            statisticLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            statisticLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 44),
        ])
        
        let cryImage = UIImageView(image: UIImage(named: "cry"))
        cryImage.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(cryImage)
        
        NSLayoutConstraint.activate([
            cryImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cryImage.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            cryImage.widthAnchor.constraint(equalToConstant: 80),
            cryImage.heightAnchor.constraint(equalToConstant: 80)
        ])
        
        let cryLabel = UILabel()
        cryLabel.text = "Анализировать пока нечего"
        cryLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        cryLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(cryLabel)
        
        NSLayoutConstraint.activate([
            cryLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cryLabel.topAnchor.constraint(equalTo:  cryImage.bottomAnchor, constant: 8),
//            cryLabel.widthAnchor.constraint(equalToConstant: 343),
//            cryLabel.heightAnchor.constraint(equalToConstant: 18)
        ])
    }
}
