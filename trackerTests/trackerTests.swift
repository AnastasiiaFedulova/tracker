//
//  trackerTests.swift
//  trackerTests
//
//  Created by Anastasiia on 23.04.2025.
//

import XCTest
import SnapshotTesting
@testable import tracker

final class trackerTests: XCTestCase {
    
    func testViewControllerWithFixedTrackers() {
        let viewModel = TrackerViewModel()
        viewModel.loadFixedTrackersForTest() // Загружаем данные для теста

        let vc = ViewController()
        vc.loadViewIfNeeded()
        vc.view.layoutIfNeeded()

        assertSnapshots(of: vc, as: [.image])
    }
    }

//import XCTest
//import SnapshotTesting
//@testable import tracker
//
//final class trackerTests: XCTestCase {
//    
//    func testViewControllerWithFixedTrackers() {
//        let viewModel = TrackerViewModel()
//        viewModel.loadFixedTrackersForTest() // Загружаем данные для теста
//
//        let vc = ViewController()
//        vc.loadViewIfNeeded()
//        vc.view.layoutIfNeeded()
//
//        // Скриншот для светлой темы
//        assertSnapshot(of: vc, as: .image(traits: .init(userInterfaceStyle: .light)), named: "light")
//
//        // Скриншот для тёмной темы
//        assertSnapshot(of: vc, as: .image(traits: .init(userInterfaceStyle: .dark)), named: "dark")
//    }
//}
