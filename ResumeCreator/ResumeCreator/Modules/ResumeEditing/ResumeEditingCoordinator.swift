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
    func workInfoAdding(workInfoEditing: WorkInfoModel, successCompletion: @escaping ((WorkInfoModel) -> Void)) {
        let dependencies = WorkInfoViewController.Dependencies(
            viewModelFactory: WorkInfoViewModelFactory(
                dependencies: WorkInfoViewModelFactory.Dependencies(
                    workInfoEditing: workInfoEditing,
                    successSaveCompletion: successCompletion
                )
            )
        )
        let childCoordinator = WorkInfoCoordinator(navigationController: navigationController, dependencies: dependencies)
        childCoordinator.parentCoordinator = self
        childCoordinators.append(childCoordinator)
        childCoordinator.start()
    }
}

extension ResumeEditingCoordinator: EducationDetailAddingRoute {
    func educationDetailAdding(educationDetailEditing: EducationDetailModel, successCompletion: @escaping ((EducationDetailModel) -> Void)) {
        let dependencies = EducationDetailViewController.Dependencies(
            viewModelFactory: EducationDetailModelFactory(
                dependencies: EducationDetailModelFactory.Dependencies(
                    educationDetailEditing: educationDetailEditing,
                    successSaveCompletion: successCompletion
                )
            )
        )
        let childCoordinator = EducationDetailCoordinator(navigationController: navigationController, dependencies: dependencies)
        childCoordinator.parentCoordinator = self
        childCoordinators.append(childCoordinator)
        childCoordinator.start()
    }
}

extension ResumeEditingCoordinator: ProjectDetailAddingRoute {
    func projectDetailAdding(projectDetailEditing: ProjectDetailModel, successCompletion: @escaping ((ProjectDetailModel) -> Void)) {
        let dependencies = ProjectDetailViewController.Dependencies(
            viewModelFactory: ProjectDetailModelFactory(
                dependencies: ProjectDetailModelFactory.Dependencies(
                    projectDetailEditing: projectDetailEditing,
                    successSaveCompletion: successCompletion
                )
            )
        )

        let childCoordinator = ProjectDetailCoordinator(navigationController: navigationController, dependencies: dependencies)
        childCoordinator.parentCoordinator = self
        childCoordinators.append(childCoordinator)
        childCoordinator.start()
    }
}

protocol ResumeEditingRoute: AnyObject {
    func resumeEditingShow(resume: ResumeModel)
}
