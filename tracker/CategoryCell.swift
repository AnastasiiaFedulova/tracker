//
//  CategoryCell.swift
//  tracker
//
//  Created by Anastasiia on 10.04.2025.
//
import UIKit

final class CategoryCell: UITableViewCell {
    
    private let separator = UIView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupSeparator()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSeparator()
    }
    
    private func setupSeparator() {
        separator.backgroundColor = .greyButton
        
        separator.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(separator)
        
        NSLayoutConstraint.activate([
            separator.heightAnchor.constraint(equalToConstant: 0.5),
            separator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            separator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            separator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    func hideSeparator(_ hide: Bool) {
        separator.isHidden = hide
    }
}

