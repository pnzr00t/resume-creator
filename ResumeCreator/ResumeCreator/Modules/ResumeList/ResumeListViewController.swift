//
//  ViewController.swift
//  ResumeCreator
//
//  Created by Oleg Pustoshkin on 12.04.2022.
//

import RxCocoa
import RxSwift
import UIKit
import SnapKit


class ResumeListViewController: UIViewController {
    struct Dependencies {
        let viewModelFactory: ResumeListViewModelFactory
    }
    
    private let dependencies: Dependencies
    weak var coordinator: ResumeEditingRoute?

    private lazy var barButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: nil, action: nil)

    private lazy var tableView = UITableView()
    private let cellReuseIdentifier = "cell"
    private var resumeList = [ResumeModel]()
    private let selectResumePublisher = PublishRelay<ResumeModel>()
    private let deleteResumePublisher = PublishRelay<ResumeModel>()

    private let disposeBag = DisposeBag()
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        resumeList = ResumeMockService().getResumeList()
        commonInit()
        setupBindings()
    }

    private func setupBindings() {
        let viewModel = dependencies.viewModelFactory.createViewModel(
            ResumeListViewModelFactory.Input(
                viewWillAppear: rx.viewWillAppear.asSignal(),
                addButtonPressed: barButtonItem.rx.tap.asSignal(),
                selectedResume: selectResumePublisher.asSignal(),
                deleteResume: deleteResumePublisher.asSignal()
            )
        )

        viewModel.cells.asDriver(onErrorJustReturn: [])
            .drive(onNext: { [weak self] resumeList in
                guard let self = self else { return }
                
                self.resumeList = resumeList
                self.tableView.reloadData()
            })
            .disposed(by: disposeBag)

        viewModel.editResume.asObservable()
            .subscribe(onNext: { [weak self] resumeModel in
                guard let self = self else { return }
                
                self.coordinator?.resumeEditingShow(resume: resumeModel)
            })
            .disposed(by: disposeBag)
    }
    
    private func commonInit() {
        navigationItem.rightBarButtonItem = barButtonItem

        view.backgroundColor = .white

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
        selectResumePublisher.accept(resumeList[indexPath.row])
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Some trick with completion handler on delete animation
            // Problem with auto update resumeList after deleteResumePublisher
            // Best solution will be using RXDataSource
            let deletedResume = resumeList.remove(at: indexPath.row)
            CATransaction.begin()
            tableView.beginUpdates()
            CATransaction.setCompletionBlock { [weak self] in
                guard let self = self else { return }
                self.deleteResumePublisher.accept(deletedResume)
            }
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.endUpdates()
            CATransaction.commit()
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
