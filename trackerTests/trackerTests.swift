//
//  trackerTests.swift
//  trackerTests
//
//  Created by Anastasiia on 23.04.2025.
//
import XCTest
import SnapshotTesting
@testable import tracker

final class TrackerTests: XCTestCase {

    func testViewControllerSnapshot() {

                let vc = ViewController()
                vc.loadViewIfNeeded()
                vc.view.layoutIfNeeded()

        assertSnapshot(matching: vc, as: .image)
    }
}



