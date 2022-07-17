//
//  ReactiveTableViewViewController.swift
//  ResumeCreator
//
//  Created by Oleg Pustoshkin on 17.07.2022.
//

import RxCocoa
import RxSwift
import UIKit
import SnapKit

class ReactiveTableViewViewController<T, CellType: UITableViewCell & ReusableIdentifierProtocol>: UIViewController, UITableViewDataSource, UITableViewDelegate {

    internal var dataList = [T]()
    //private let selectElementPublisher = PublishRelay<T>()
    //private let deleteElementPublisher = PublishRelay<T>()
    private let selectElementPublisher = PublishRelay<IndexPath>()
    private let deleteElementPublisher = PublishRelay<IndexPath>()


    internal let tableView = SelfSizedTableView()

    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        commonInit()
    }

    private func commonInit() {
        view.backgroundColor = .white

       
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CellType.self, forCellReuseIdentifier: CellType.reusableIdentifier)
    }

    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //selectElementPublisher.accept(dataList[indexPath.row])
        selectElementPublisher.accept(indexPath)
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Some trick with completion handler on delete animation
            // Problem with auto update resumeList after deleteResumePublisher
            // Best solution will be using RXDataSource
            let deletedResume = dataList.remove(at: indexPath.row)
            CATransaction.begin()
            tableView.beginUpdates()
            CATransaction.setCompletionBlock { [weak self] in
                guard let self = self else { return }
                //self.deleteElementPublisher.accept(deletedResume)
                self.deleteElementPublisher.accept(indexPath)
            }
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.endUpdates()
            CATransaction.commit()
        }
    }

    // MARK: - UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        getCellForRowAtIndexPath(indexPath)
    }

    func getCellForRowAtIndexPath(_ indexPath: IndexPath) -> UITableViewCell {
        // If something forgot override, throw error
        fatalError("getCellForRowAtIndexPath(_ indexPath: IndexPath) has not been implemented")
    }

    func setNewData(dataList: [T]) {
        self.dataList = dataList
        self.tableView.reloadData()
    }
}

extension ReactiveTableViewViewController {
    struct Reactive<T> {
        let base: ReactiveTableViewViewController<T, CellType>
        
        fileprivate init(_ base: ReactiveTableViewViewController<T, CellType>) {
            self.base = base
        }
    }
    
    var reactive: Reactive<T> {
        return Reactive(self)
    }
}

extension ReactiveTableViewViewController.Reactive {
    /*var selectElement: ControlEvent<T> {
        ControlEvent(events: base.selectElementPublisher)
    }

    var deleteElement: ControlEvent<T> {
        ControlEvent(events: base.deleteElementPublisher)
    }*/

    var selectElement: ControlEvent<IndexPath> {
        ControlEvent(events: base.selectElementPublisher)
    }

    var deleteElement: ControlEvent<IndexPath> {
        ControlEvent(events: base.deleteElementPublisher)
    }
}
