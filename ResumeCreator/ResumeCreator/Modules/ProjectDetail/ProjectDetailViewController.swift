//
//  ProjectDetailViewController.swift
//  ResumeCreator
//
//  Created by Oleg Pustoshkin on 13.04.2022.
//

import RxCocoa
import RxSwift
import Foundation
import UIKit

struct ProjectDetailModelFactory {
    struct Dependencies {
        let projectDetailEditing: ProjectDetailModel
        let successSaveCompletion: (ProjectDetailModel) -> Void
    }

    var dependencies: Dependencies
    private var projectDetailState: StateWrapper<ProjectDetailModel>
    private let disposeBag = DisposeBag()

    init(dependencies: Dependencies) {
        self.dependencies = dependencies
        self.projectDetailState = StateWrapper<ProjectDetailModel>(state: dependencies.projectDetailEditing)
    }

    struct Input {
        let viewWillAppear: Signal<Void>
        let saveResume: Signal<Void>
        //let resumeNameText: Driver<String>
    }

    struct ViewModel {
        //let allFieldValid: Driver<Bool>
    }

    func createViewModel(_ input: Input) -> ViewModel {

        input.saveResume.asObservable()
            .subscribe(onNext: {
                dependencies.successSaveCompletion(projectDetailState.state)
            })
            .disposed(by: disposeBag)

        /*let resumeNameValid = input.resumeNameText.map({ $0.count > 0 }).asSignal(onErrorJustReturn: true)
        let allFieldValid = Signal.merge(resumeNameValid)
            .startWith(false)*/

        return ViewModel(
            /*allFieldValid: allFieldValid*/
        )
    }
}

class ProjectDetailViewController: UIViewController {
    struct Dependencies {
        let viewModelFactory: ProjectDetailModelFactory
    }
    
    private let dependencies: Dependencies
    weak var coordinator: ProjectDetailCoordinator?

    private lazy var barButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: nil, action: nil)

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
        // Do any additional setup after loading the view.
        view.backgroundColor = .green
        commonInit()
        setupBindings()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        if self.isMovingFromParent {
            coordinator?.viewDidDisappear()
        }
    }

    private func commonInit() {
        navigationItem.rightBarButtonItem = barButtonItem

        title = "Project info editing"
    }

    private func setupBindings() {
        let viewModel = dependencies.viewModelFactory.createViewModel(
            ProjectDetailModelFactory.Input(
                viewWillAppear: rx.viewWillAppear.asSignal(),
                saveResume: barButtonItem.rx.tap.asSignal()
            )
        )
        
        /*viewModel.allFieldValid
            .drive(onNext: { [weak self] isValid in
                guard let self = self else { return }

                self.barButtonItem.isEnabled = isValid
            })
            .disposed(by: disposeBag)*/
    }
}
