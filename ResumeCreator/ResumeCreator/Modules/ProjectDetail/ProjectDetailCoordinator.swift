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

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let vc = ProjectDetailViewController()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: false)
    }
}

protocol ProjectDetailAddingRoute: AnyObject {
    func projectDetailAdding()
}
