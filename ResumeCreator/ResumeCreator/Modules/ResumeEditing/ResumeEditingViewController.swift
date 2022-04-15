//
//  ResumeEditingViewController.swift
//  ResumeCreator
//
//  Created by Oleg Pustoshkin on 14.04.2022.
//

import Foundation
import UIKit

class ResumeEditingViewController: UIViewController {
    weak var coordinator: (WorkInfoAddingRoute & EducationDetailAddingRoute & ProjectDetailAddingRoute)?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = .green
    }
}
