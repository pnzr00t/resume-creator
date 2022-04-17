//
//  ProjectDetailCoordinator.swift
//  ResumeCreator
//
//  Created by Oleg Pustoshkin on 13.04.2022.
//

import Foundation
import UIKit

class ProjectDetailCoordinator: Coordinator {
    weak var parentCoordinator: Coordinator?
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    private var dependencies: ProjectDetailViewController.Dependencies

    init(navigationController: UINavigationController, dependencies: ProjectDetailViewController.Dependencies) {
        self.navigationController = navigationController
        self.dependencies = dependencies
    }

    func start() {
        let vc = ProjectDetailViewController(dependencies: dependencies)
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
}

protocol ProjectDetailAddingRoute: AnyObject {
    func projectDetailAdding(projectDetailEditing: ProjectDetailModel, successCompletion: @escaping ((ProjectDetailModel) -> Void))
}
