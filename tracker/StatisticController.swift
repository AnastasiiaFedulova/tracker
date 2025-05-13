import UIKit

final class StatisticController: UIViewController {
    
    private var card: UIView?
    private let numberLabel = UILabel()
    private let cryImage: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "cry"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isHidden = true
        return imageView
    }()
    
    private let cryLabel: UILabel = {
        let label = UILabel()
        label.text = "Анализировать пока нечего"
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        return label
    }()
    
    private var gradientLayer: CAGradientLayer?
    
    var completedTrackers: [UUID: [String]] = [:] {
        didSet {
            updateStatistic()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleCompletedTrackersUpdate(_:)),
            name: .completedTrackersUpdated,
            object: nil
        )
        
        let titleLabel = UILabel()
        titleLabel.text = "Статистика"
        titleLabel.textColor = .black
        titleLabel.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 44),
        ])
        
        let card = UIView()
        self.card = card
        card.backgroundColor = .white
        card.layer.cornerRadius = 16
        card.layer.masksToBounds = false
        card.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(card)
        
        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 77),
            card.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            card.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            card.heightAnchor.constraint(equalToConstant: 90)
        ])
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor(red: 0.98, green: 0.27, blue: 0.27, alpha: 1.0).cgColor,
            UIColor(red: 0.0, green: 0.68, blue: 0.43, alpha: 1.0).cgColor,
            UIColor(red: 0.2, green: 0.45, blue: 0.9, alpha: 1.0).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradientLayer.cornerRadius = 16
        card.layer.insertSublayer(gradientLayer, at: 0)
        self.gradientLayer = gradientLayer
        
        let innerView = UIView()
        innerView.backgroundColor = .white
        innerView.layer.cornerRadius = 16
        innerView.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(innerView)
        
        NSLayoutConstraint.activate([
            innerView.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 3),
            innerView.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -3),
            innerView.topAnchor.constraint(equalTo: card.topAnchor, constant: 3),
            innerView.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -3)
        ])
        
        numberLabel.text = "0"
        numberLabel.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        numberLabel.textColor = .black
        numberLabel.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(numberLabel)
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = "Трекеров завершено"
        subtitleLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        subtitleLabel.textColor = .black
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(subtitleLabel)
        
        NSLayoutConstraint.activate([
            numberLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            numberLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            
            subtitleLabel.topAnchor.constraint(equalTo: numberLabel.bottomAnchor, constant: 7),
            subtitleLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12)
        ])
        
        view.addSubview(cryImage)
        NSLayoutConstraint.activate([
            cryImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cryImage.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            cryImage.widthAnchor.constraint(equalToConstant: 80),
            cryImage.heightAnchor.constraint(equalToConstant: 80)
        ])
        
        view.addSubview(cryLabel)
        NSLayoutConstraint.activate([
            cryLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cryLabel.topAnchor.constraint(equalTo: cryImage.bottomAnchor, constant: 8)
        ])
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let card = view.subviews.first(where: { $0.layer.sublayers?.contains(gradientLayer!) == true }) {
            gradientLayer?.frame = card.bounds
            
            let maskLayer = CAShapeLayer()
            let outerPath = UIBezierPath(roundedRect: card.bounds, cornerRadius: 16)
            let innerPath = UIBezierPath(roundedRect: card.bounds.insetBy(dx: 1.5, dy: 1.5), cornerRadius: 14)
            outerPath.append(innerPath)
            maskLayer.path = outerPath.cgPath
            maskLayer.fillRule = .evenOdd
            gradientLayer?.mask = maskLayer
        }
    }
    
    @objc private func handleCompletedTrackersUpdate(_ notification: Notification) {
        guard let data = notification.userInfo?["data"] as? [UUID: [String]] else { return }
        completedTrackers = data
    }
    
    private func updateStatistic() {
        let totalCompleted = completedTrackers.values.reduce(0) { $0 + $1.count }
        numberLabel.text = "\(totalCompleted)"
        
        let showEmptyState = totalCompleted == 0
        
        cryImage.isHidden = !showEmptyState
        cryLabel.isHidden = !showEmptyState
        card?.isHidden = showEmptyState
    }
    
}

extension Notification.Name {
    static let completedTrackersUpdated = Notification.Name("completedTrackersUpdated")
}
