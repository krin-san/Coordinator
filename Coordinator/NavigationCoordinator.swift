//
//  NavigationCoordinator.swift
//  Radiant Tap Essentials
//
//  Copyright © 2017 Radiant Tap
//  MIT License · http://choosealicense.com/licenses/mit/
//

import UIKit

open class NavigationCoordinator: Coordinator<UINavigationController>, UINavigationControllerDelegate {
	//	References to actual UIViewControllers managed by this Coordinator instance.
	open var viewControllers: [UIViewController] = []

	///	This method is implemented to detect when "pop" happens.
	///	`popViewController` must be detected in order to remove popped VC from Coordinator's `viewControllers` array.
	///
	///	It is strongly advised to *not* override this method, but it's allowed to do so in case you really need to.
	///	What you likely want to override is `handlePopBack(to:)` method.
	open func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
		print("> \(type(of: self)).\(#function):\(#line) \(self) navCtrl: \(navigationController) didShow: \(viewController)")
		let fromViewController = navigationController.transitionCoordinator?.viewController(forKey: .from)
		print("  - coordinator: \(navigationController.transitionCoordinator) from: \(fromViewController)")
		self.didShowController(viewController, fromViewController: fromViewController)
	}

	public func present(_ vc: UIViewController) {
		rootViewController.present(vc, animated: true, completion: nil)
	}

	public func dismiss() {
		rootViewController.dismiss(animated: true, completion: nil)
	}

	///	Main method to push supplied UIVC to the navigation stack.
	///	First it adds the `vc` to the Coordinator's `viewControllers` then calls `show(vc)` on the root.
	public func show(_ vc: UIViewController) {
		viewControllers.append(vc)
		rootViewController.show(vc, sender: self)
	}

	///	Clears entire navigation stack on both the Coordinator and UINavigationController by
	/// setting this `[vc]` on respective `viewControllers` property.
	public func root(_ vc: UIViewController) {
		viewControllers = [vc]
		rootViewController.viewControllers = [vc]
	}

	///	Replaces current top UIVC in the navigation stack (currently visible UIVC) in the root
	///	with the supplied `vc` instance.
	public func top(_ vc: UIViewController) {
		if viewControllers.count == 0 {
			root(vc)
			return
		}
		viewControllers.removeLast()
		rootViewController.viewControllers.removeLast()
		show(vc)
	}

	///	Pops back to the given instance, removing one or more UIVCs from the navigation stack.
	public func pop(to vc: UIViewController, animated: Bool = true) {
		guard let index = viewControllers.index(of: vc) else { return  }

		let lastPosition = viewControllers.count - 1
		if lastPosition > 0 {
			viewControllers = Array(viewControllers.dropLast(lastPosition - index))
		}

		rootViewController.popToViewController(vc, animated: animated)
	}

	///	If you subclass NavigationCoordinator, then override this method if you need to
	///	do something special when customer taps the UIKit's backButton in the navigationBar.
	///
	///	By default, this does nothing.
	open func handlePopBack(to vc: UIViewController?) {
        print("  - \(#function) \(vc?.title) among \(viewControllers.map { $0.title })")
	}

	open override func start(with completion: @escaping () -> Void) {
		//	assign itself as UINavigationControllerDelegate
		rootViewController.delegate = self
		//	must call this
		super.start(with: completion)
	}

	open override func stop(with completion: @escaping () -> Void) {
		//	relinquish being delegate for UINC
		rootViewController.delegate = nil

		//	remove all of its UIVCs from the root UINC
		for vc in viewControllers {
			guard let index = rootViewController.viewControllers.index(of: vc) else { continue }
			rootViewController.viewControllers.remove(at: index)
		}
		//	clean up UIVC instances
		viewControllers.removeAll()
		//	must call this
		super.stop(with: completion)
	}

	open override func activate() {
		//	take back ownership over root (UINavigationController)
		super.activate()
		//	assign itself again as `UINavigationControllerDelegate`
		rootViewController.delegate = self
		//	re-assign own content View Controllers
		rootViewController.viewControllers = viewControllers
	}
}

private extension NavigationCoordinator {
	func didShowController(_ viewController: UIViewController, fromViewController: UIViewController?) {
        if let fromViewController = fromViewController {
            guard viewControllers.contains(fromViewController) else {
                print("  - \(fromViewController) not found in \(viewControllers)")
                return
            }
            guard let last = viewControllers.last, last === fromViewController else {
                print("  - \(fromViewController) is not the last controller \(viewControllers.last)")
                return
            }

            if let index = viewControllers.firstIndex(of: viewController) {
                let lastPosition = viewControllers.count - 1
                print("  - removing \(lastPosition - index) last controllers from \(viewControllers.map { $0.title })")
                viewControllers = Array(viewControllers.dropLast(lastPosition - index))
                handlePopBack(to: viewController)
            } else {
                print("  - removing just 1 last controller from \(viewControllers.map { $0.title })")
                viewControllers.removeLast()
                handlePopBack(to: last)
            }
        } else {
            guard viewController !== viewControllers.last else {
                print("  - \(viewController) is the last item in array. It can't be a pop event")
                return
            }
            guard let index = viewControllers.firstIndex(of: viewController) else {
                print("  - \(viewController) not found in \(viewControllers)")
                return
            }

            let lastPosition = viewControllers.count - 1
            print("  - removing \(lastPosition - index) last controllers from \(viewControllers.map { $0.title })")
            viewControllers = Array(viewControllers.dropLast(lastPosition - index))
            handlePopBack(to: viewController)
        }

		//	is there any controller left shown in this Coordinator?
		if viewControllers.count == 0 {
			print("  - didFinish:")
			//	inform the parent Coordinator that this child Coordinator has no more VCs
			parent?.coordinatorDidFinish(self, completion: {})
			return
		}
	}
}
