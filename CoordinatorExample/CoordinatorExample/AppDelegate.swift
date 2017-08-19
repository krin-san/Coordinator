//
//  AppDelegate.swift
//  CoordinatorExample
//
//  Created by Aleksandar Vacić on 23.11.16..
//  Copyright © 2016. Radiant Tap. All rights reserved.
//

import UIKit
import Coordinator

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
	var window: UIWindow?
	var applicationCoordinator: AppCoordinator!

	func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
		window = UIWindow(frame: UIScreen.main.bounds)

		applicationCoordinator = AppCoordinator()
		window?.rootViewController = applicationCoordinator.rootViewController

		return true
	}

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

		window?.makeKeyAndVisible()
		applicationCoordinator.start()

		return true
	}
}

