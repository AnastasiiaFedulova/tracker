//
//  OnboardingViewController.swift
//  tracker
//
//  Created by Anastasiia on 07.04.2025.
//
import UIKit

class OnboardingViewController: UIPageViewController {
    
    var onFinish: (() -> Void)?
    
    private lazy var pages: [OnboardingPageViewController] = {
        let first = OnboardingPageViewController(
            imageName: "backgrBlue",
            text: "Отслеживайте только \n то, что хотите",
            showButton: true
        )
        
        let second = OnboardingPageViewController(
            imageName: "backgrRed",
            text: "Даже если это \n не литры воды и йога",
            showButton: true
        )
        
        [first, second].forEach { $0.onFinish = { [weak self] in self?.onFinishTapped() } }
        
        return [first, second]
    }()
    
    private let pageControl: UIPageControl = {
        let pc = UIPageControl()
        pc.currentPageIndicatorTintColor = .forText
        pc.pageIndicatorTintColor = UIColor.forText.withAlphaComponent(0.3)
        pc.translatesAutoresizingMaskIntoConstraints = false
        return pc
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        delegate = self
        
        if let first = pages.first {
            setViewControllers([first], direction: .forward, animated: true)
        }
        
        view.addSubview(pageControl)
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
        
        NSLayoutConstraint.activate([
            pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -168),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func onFinishTapped() {
        onFinish?()
    }
}

extension OnboardingViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = pages.firstIndex(of: viewController as! OnboardingPageViewController), index > 0 else { return nil }
        return pages[index - 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = pages.firstIndex(of: viewController as! OnboardingPageViewController), index < pages.count - 1 else { return nil }
        return pages[index + 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if let current = pageViewController.viewControllers?.first,
           let index = pages.firstIndex(of: current as! OnboardingPageViewController) {
            pageControl.currentPage = index
        }
    }
}
