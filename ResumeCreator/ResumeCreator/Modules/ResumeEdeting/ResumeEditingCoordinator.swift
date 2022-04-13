//
//  ResumeEditingCoordinator.swift
//  ResumeCreator
//
//  Created by Oleg Pustoshkin on 14.04.2022.
//

import Foundation
import UIKit

class ResumeEditingCoordinator: Coordinator {
    weak var parentCoordinator: Coordinator?
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let vc = ResumeEditingViewController()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: false)
    }
}

extension ResumeEditingCoordinator: WorkInfoAddingRoute {
    func workInfoAdding() {
        let childCoordinator = WorkInfoCoordinator(navigationController: navigationController)
        childCoordinator.parentCoordinator = self
        childCoordinators.append(childCoordinator)
        childCoordinator.start()
    }
}

extension ResumeEditingCoordinator: EducationDetailAddingRoute {
    func educationDetailAdding() {
        let childCoordinator = EducationDetailCoordinator(navigationController: navigationController)
        childCoordinator.parentCoordinator = self
        childCoordinators.append(childCoordinator)
        childCoordinator.start()
    }
}

extension ResumeEditingCoordinator: ProjectDetailAddingRoute {
    func projectDetailAdding() {
        let childCoordinator = ProjectDetailCoordinator(navigationController: navigationController)
        childCoordinator.parentCoordinator = self
        childCoordinators.append(childCoordinator)
        childCoordinator.start()
    }
}

protocol ResumeEditingRoute: AnyObject {
    func resumeEditingShow()
}
