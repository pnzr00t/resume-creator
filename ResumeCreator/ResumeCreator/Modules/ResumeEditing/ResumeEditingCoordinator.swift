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
    private var dependencies: ResumeEditingViewController.Dependencies

    init(navigationController: UINavigationController, dependencies: ResumeEditingViewController.Dependencies) {
        self.navigationController = navigationController
        self.dependencies = dependencies
    }

    func start() {
        let vc = ResumeEditingViewController(dependencies: self.dependencies)
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
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
    func resumeEditingShow(resume: ResumeModel)
}
