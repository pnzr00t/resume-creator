//
//  ViewController.swift
//  ResumeCreator
//
//  Created by Oleg Pustoshkin on 12.04.2022.
//

import UIKit

class ResumeListViewController: UIViewController {
    weak var coordinator: ResumeEditingRoute?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = .green
        title = "Resume list"
    }
}

