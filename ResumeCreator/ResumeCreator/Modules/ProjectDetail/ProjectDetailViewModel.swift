//
//  ProjectDetailViewModel.swift
//  ResumeCreator
//
//  Created by Oleg Pustoshkin on 18.04.2022.
//

import RxCocoa
import RxSwift
import Foundation
import UIKit

struct ProjectDetailViewModelFactory {
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
        let projectNameText: Driver<String>
        let teamSize: Driver<Int>
        let projectSummary: Driver<String>
        let technologyUsed: Driver<String>
        let role: Driver<String>
    }

    struct ViewModel {
        let projectNameText: Driver<String>
        let allFieldValid: Driver<Bool>
        let teamSize: Driver<Int>
        let projectSummary: Driver<String>
        let technologyUsed: Driver<String>
        let role: Driver<String>
    }

    func createViewModel(_ input: Input) -> ViewModel {

        let projectNameText = input.projectNameText
            .do(onNext: {
                projectDetailState.state.projectName = $0
            })
            .startWith(projectDetailState.state.projectName)

        input.saveResume.asObservable()
            .subscribe(onNext: {
                dependencies.successSaveCompletion(projectDetailState.state)
            })
            .disposed(by: disposeBag)

        let teamSize = input.teamSize
            .do(onNext: { teamSize in
                projectDetailState.state.teamSize = teamSize
            })
            .startWith(projectDetailState.state.teamSize)
        
        let projectSummary = input.projectSummary
            .do(onNext: {
                projectDetailState.state.projectSummary = $0
            })
            .startWith(projectDetailState.state.projectSummary)

        let technologyUsed = input.technologyUsed
            .do(onNext: {
                projectDetailState.state.technologyUsed = $0
            })
            .startWith(projectDetailState.state.technologyUsed)

        let role = input.role
            .do(onNext: {
                projectDetailState.state.role = $0
            })
            .startWith(projectDetailState.state.role)

        let companyNameValid = projectNameText.map({ $0.count > 0 }).asSignal(onErrorJustReturn: true)
        let allFieldValid = Signal.merge(companyNameValid)
            .startWith(false)

        return ViewModel(
            projectNameText: projectNameText,
            allFieldValid: allFieldValid.asDriver(onErrorJustReturn: true),
            teamSize: teamSize.asDriver().asDriver(onErrorJustReturn: 0),
            projectSummary: projectSummary.asDriver().asDriver(onErrorJustReturn: ""),
            technologyUsed: technologyUsed.asDriver().asDriver(onErrorJustReturn: ""),
            role: role.asDriver().asDriver(onErrorJustReturn: "")
        )
    }
}
