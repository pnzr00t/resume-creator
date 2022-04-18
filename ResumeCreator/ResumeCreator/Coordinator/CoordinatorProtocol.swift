//
//  CoordinatorProtocol.swift
//  ResumeCreator
//
//  Created by Oleg Pustoshkin on 13.04.2022.
//

import UIKit

protocol Coordinator: AnyObject {
    var parentCoordinator: Coordinator? { get set }
    var childCoordinators: [Coordinator] { get set }
    var navigationController: UINavigationController { get set }

    func start()
    func viewDidDisappear()
    func childDidFinish(_ child: Coordinator?)
}

extension Coordinator {
    // Very danger solution of coordinator chain, but it's simple and fast
    func viewDidDisappear() {
        parentCoordinator?.childDidFinish(self)
    }

    func childDidFinish(_ child: Coordinator?) {
        for (index, coordinator) in childCoordinators.enumerated() {
            if coordinator === child {
                childCoordinators.remove(at: index)
                break
            }
        }
    }
}
