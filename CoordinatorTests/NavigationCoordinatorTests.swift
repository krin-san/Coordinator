//
//  NavigationCoordinatorTests.swift
//  Tests
//
//  Created by Krin-San on 1/22/19.
//  Copyright © 2019 Radiant Tap. All rights reserved.
//

import XCTest
import Coordinator

class ReportingNavigationCoordinator: NavigationCoordinator {

    var navigationChangeExpectation: XCTestExpectation?

    override func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        super.navigationController(navigationController, didShow: viewController, animated: animated)

        navigationChangeExpectation?.fulfill()
        navigationChangeExpectation = nil
    }

    var wasStopped = false

    override func stop(with completion: @escaping () -> Void) {
        super.stop(with: completion)

        wasStopped = true
    }

}

class NavigationCoordinatorTests: XCTestCase {

    let window = UIWindow(frame: CGRect(origin: .zero, size: CGSize(width: 640, height: 1136)))

    let toPush = 3
    let navigationController = UINavigationController()
    var main: ReportingNavigationCoordinator!

    override func setUp() {
        super.setUp()

        continueAfterFailure = false

        main = ReportingNavigationCoordinator(rootViewController: navigationController)
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        main.start {}
    }

    // MARK: - Single coordinator tests

    func _testPushOutsideCoordinator() {
        pushInitialController(coordinator: main, title: "#0")

        let viewController = UIViewController()
        viewController.title = "Controller pushed outside of coordinator"

        XCTAssertEqual(main.viewControllers.count, 1)
        XCTAssertEqual(navigationController.viewControllers.count, 1)

        print(">>> Push")
        navigationController.pushViewController(viewController, animated: false)

        XCTAssertFalse(main.wasStopped)
        XCTAssertEqual(main.viewControllers.count, 1)
        XCTAssertEqual(navigationController.viewControllers.count, 2)

        print(">>> Pop")
        navigationController.popViewController(animated: false)

        XCTAssertFalse(main.wasStopped)
        XCTAssertEqual(main.viewControllers.count, 1)
        XCTAssertEqual(navigationController.viewControllers.count, 1)
    }

    func testPopAnimated() {
        pushInitialControllers()
        pop(animated: true)
    }

    func testPopNotAnimated() {
        pushInitialControllers()
        pop(animated: false)
    }

    func testPopToRootAnimated() {
        pushInitialControllers()
        popToRoot(animated: true)
    }

    func testPopToRootNotAnimated() {
        pushInitialControllers()
        popToRoot(animated: false)
    }

    private func pushInitialControllers() {
        for i in 0..<toPush {
            pushInitialController(coordinator: main, title: "#\(i)")
        }

        XCTAssertEqual(main.viewControllers, navigationController.viewControllers)
        XCTAssertEqual(main.viewControllers.count, toPush)
        XCTAssertEqual(navigationController.viewControllers.count, toPush)
    }

    private func pop(animated: Bool) {
        main.navigationChangeExpectation = expectation(description: "Controllers popped")
        navigationController.popViewController(animated: animated)

        waitForExpectations(timeout: 1)

        XCTAssertEqual(main.viewControllers, navigationController.viewControllers)
        XCTAssertEqual(main.viewControllers.count, toPush - 1)
        XCTAssertEqual(navigationController.viewControllers.count, toPush - 1)
    }

    private func popToRoot(animated: Bool) {
        main.navigationChangeExpectation = expectation(description: "Controllers popped")
        let popped = navigationController.popToRootViewController(animated: animated)

        waitForExpectations(timeout: 1)

        XCTAssertEqual(main.viewControllers, navigationController.viewControllers)
        XCTAssertEqual(main.viewControllers.count, 1)
        XCTAssertEqual(navigationController.viewControllers.count, 1)
        XCTAssertTrue(popped?.count == (toPush - 1))
    }

    // MARK: - Multi-coordinator tests

    func testPopDetection() {
        pushInitialControllers()

        let child = ReportingNavigationCoordinator(rootViewController: main.rootViewController)
        main.startChild(coordinator: child)
        pushInitialController(coordinator: child, title: "#0 @ child")

        child.navigationChangeExpectation = expectation(description: "Controller popped")
        navigationController.popViewController(animated: true)
        waitForExpectations(timeout: 1)

        XCTAssertTrue(child.wasStopped)
    }

    // MARK: - Helpers

    private func pushInitialController(coordinator: ReportingNavigationCoordinator, title: String) {
        let initialCount = navigationController.viewControllers.count

        coordinator.navigationChangeExpectation = expectation(description: "Controller \(title) is shown")

        let viewController = UIViewController()
        viewController.title = title
        coordinator.show(viewController)

        waitForExpectations(timeout: 1)

        XCTAssertEqual(navigationController.viewControllers.count, initialCount + 1)
    }

}
