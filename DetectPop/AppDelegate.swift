//
//  AppDelegate.swift
//  DetectPop
//
//  Created by Alexander Chapliuk on 17.1.19.
//  Copyright © 2019 Radiant Tap. All rights reserved.
//

import UIKit
import Coordinator

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    var appCoordinator: AppCoordinator = {
        let viewController = UIStoryboard.main.instantiateInitialViewController() as? UINavigationController
        return AppCoordinator(rootViewController: viewController)
    }()

    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = appCoordinator.rootViewController

        return true
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window?.makeKeyAndVisible()
        appCoordinator.start(with: {})

        return true
    }

}
