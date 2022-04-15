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
    private let dependencies: ResumeListViewController.Dependencies

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController

        dependencies = ResumeListViewController.Dependencies(
            viewModelFactory: ResumeListViewModelFactory(
                dependencies: ResumeListViewModelFactory.Dependencies(resumeService: ResumeRealmService(realmFileName: "resume-data"))
                // FIXME: MOCK - INFO. delete this code
                //dependencies: ResumeListViewModelFactory.Dependencies(resumeService: ResumeMockService())
            )
        )
    }

    func start() {
        let vc = ResumeListViewController(dependencies: dependencies)
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: false)
    }
}

extension ResumeListCoordinator: ResumeEditingRoute {
    func resumeEditingShow(resume: ResumeModel) {
        let childCoordinator = ResumeEditingCoordinator(navigationController: navigationController, resume: resume)
        childCoordinator.parentCoordinator = self
        childCoordinators.append(childCoordinator)
        childCoordinator.start()
    }
}
