//
//  EducationDetailCoordinator.swift
//  ResumeCreator
//
//  Created by Oleg Pustoshkin on 13.04.2022.
//

import Foundation
import UIKit

class EducationDetailCoordinator: Coordinator {
    weak var parentCoordinator: Coordinator?
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    private var dependencies: EducationDetailViewController.Dependencies

    init(navigationController: UINavigationController, dependencies: EducationDetailViewController.Dependencies) {
        self.navigationController = navigationController
        self.dependencies = dependencies
    }


    func start() {
        let vc = EducationDetailViewController(dependencies: dependencies)
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
}

protocol EducationDetailAddingRoute: AnyObject {
    func educationDetailAdding(educationDetailEditing: EducationDetailModel, successCompletion: @escaping ((EducationDetailModel) -> Void))
}
