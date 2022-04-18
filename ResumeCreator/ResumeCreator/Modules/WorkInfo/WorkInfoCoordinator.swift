//
//  WorkInfoCoordinator.swift
//  ResumeCreator
//
//  Created by Oleg Pustoshkin on 13.04.2022.
//

import Foundation
import UIKit

class WorkInfoCoordinator: Coordinator {
    weak var parentCoordinator: Coordinator?
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    private var dependencies: WorkInfoViewController.Dependencies

    init(navigationController: UINavigationController, dependencies: WorkInfoViewController.Dependencies) {
        self.navigationController = navigationController
        self.dependencies = dependencies
    }

    func start() {
        let vc = WorkInfoViewController(dependencies: dependencies)
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
}

protocol WorkInfoAddingRoute: AnyObject {
    func workInfoAdding(workInfoEditing: WorkInfoModel, successCompletion: @escaping ((WorkInfoModel) -> Void))
}
