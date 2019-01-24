//
//  AppCoordinator.swift
//  DetectPop
//
//  Created by Alexander Chapliuk on 17.1.19.
//  Copyright © 2019 Radiant Tap. All rights reserved.
//

import Foundation
import Coordinator

extension UIStoryboard {

    static var main: UIStoryboard {
        return UIStoryboard(name: "Main", bundle: nil)
    }

}

extension UIResponder {

    @objc dynamic func stackSize() -> Int {
        return coordinatingResponder?.stackSize() ?? -1
    }

    @objc dynamic func pushNext(from number: Int) {
        coordinatingResponder?.pushNext(from: number)
    }

}

class AppCoordinator: NavigationCoordinator {

    override func start(with completion: @escaping () -> Void) {
        super.start(with: completion)

        pushNext(from: -1)
    }

    override func handlePopBack(to vc: UIViewController?) {
        super.handlePopBack(to: vc)

        (vc as? StackObserver)?.updateStackSize()
    }

    // MARK: Navigation
    // Note: must be placed here, due to current Swift/ObjC limitations

    override func stackSize() -> Int {
        return viewControllers.count
    }

    override func pushNext(from number: Int) {
        let viewController = UIStoryboard.main.instantiateViewController(withIdentifier: String(describing: ViewController.self)) as! ViewController
        viewController.number = number + 1
        show(viewController)
    }

}
