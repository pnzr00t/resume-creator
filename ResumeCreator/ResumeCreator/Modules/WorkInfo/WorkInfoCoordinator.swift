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

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let vc = WorkInfoViewController()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: false)
    }
}

protocol WorkInfoAddingRoute: AnyObject {
    func workInfoAdding()
}
