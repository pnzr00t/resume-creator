//
//  MainCoordinator.swift
//  ResumeCreator
//
//  Created by Oleg Pustoshkin on 13.04.2022.
//

import UIKit

class ResumeListCoordinator: Coordinator {
    weak var parentCoordinator: Coordinator?
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let vc = ResumeListViewController()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: false)
    }
}

extension ResumeListCoordinator: ResumeEditingRoute {
    func resumeEditingShow() {
        let childCoordinator = ResumeEditingCoordinator(navigationController: navigationController)
        childCoordinator.parentCoordinator = self
        childCoordinators.append(childCoordinator)
        childCoordinator.start()
    }
}
