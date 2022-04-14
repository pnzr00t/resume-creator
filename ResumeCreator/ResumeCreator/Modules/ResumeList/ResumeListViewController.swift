//
//  ViewController.swift
//  ResumeCreator
//
//  Created by Oleg Pustoshkin on 12.04.2022.
//

import UIKit
import SnapKit

class ResumeListViewController: UIViewController {
    weak var coordinator: ResumeEditingRoute?

    private lazy var tableView = UITableView()
    private let cellReuseIdentifier = "cell"
    private var resumeList = [ResumeModel]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        resumeList = ResumeMockManager().getResumeList()
        commonInit()
    }

    private func commonInit() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: nil/*#selector(addTapped)*/)
        
        view.backgroundColor = .green
        title = "Resume list"

        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
    }
}

extension ResumeListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            resumeList.remove(at: indexPath.row)

            // delete the table view row
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}

extension ResumeListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        resumeList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reusableCell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath)
        reusableCell.textLabel?.text = resumeList[indexPath.row].resumeName

        return reusableCell
    }
}
