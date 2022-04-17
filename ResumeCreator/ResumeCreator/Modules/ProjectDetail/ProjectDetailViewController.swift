//
//  ProjectDetailViewController.swift
//  ResumeCreator
//
//  Created by Oleg Pustoshkin on 13.04.2022.
//

import Foundation
import UIKit

class ProjectDetailViewController: UIViewController {
    weak var coordinator: ProjectDetailCoordinator?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = .green
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        if self.isMovingFromParent {
            coordinator?.viewDidDisappear()
        }
    }
}
