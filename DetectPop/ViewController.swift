//
//  ViewController.swift
//  DetectPop
//
//  Created by Alexander Chapliuk on 17.1.19.
//  Copyright © 2019 Radiant Tap. All rights reserved.
//

import UIKit

protocol StackObserver {
    func updateStackSize()
}

class ViewController: UIViewController {

    @IBOutlet weak var stackSizeLabel: UILabel!
    @IBOutlet weak var animationSwitch: UISwitch!
    @IBOutlet weak var popStack: UIStackView!

    static var animatePop: Bool = true
    var number: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "# \(number)"

        for i in 0...number {
            let button = UIButton(type: .system)

            button.tag = i
            button.setTitle("#\(i)", for: .normal)
            button.addTarget(self, action: #selector(popWith(_:)), for: .touchUpInside)

            if i == number {
                button.isEnabled = false
            }

            popStack.addArrangedSubview(button)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        animationSwitch.isOn = ViewController.animatePop
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        updateStackSize()
    }

    // MARK: Navigation

    @IBAction func switchAnimation(_ sender: UISwitch) {
        ViewController.animatePop = sender.isOn
    }

    @IBAction func popBack(_ sender: Any) {
        navigationController?.popViewController(animated: ViewController.animatePop)
    }

    @IBAction func pushNext(_ sender: Any) {
        pushNext(from: number)
    }

    @objc func popWith(_ sender: UIButton) {
        let index = sender.tag

        guard let navigationController = navigationController else {
            fatalError("Should exist")
        }
        guard navigationController.viewControllers.count > index else {
            fatalError("Out of bounds")
        }

        let viewController = navigationController.viewControllers[index]
        navigationController.popToViewController(viewController, animated: ViewController.animatePop)
    }

}

extension ViewController: StackObserver {

    func updateStackSize() {
        stackSizeLabel.text = "Navigation stack size: \(stackSize())"
    }

}
