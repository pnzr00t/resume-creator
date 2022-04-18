//
//  WorkInfoViewModel.swift
//  ResumeCreator
//
//  Created by Oleg Pustoshkin on 18.04.2022.
//

import RxCocoa
import RxSwift
import Foundation
import UIKit

struct WorkInfoViewModelFactory {
    struct Dependencies {
        let workInfoEditing: WorkInfoModel
        let successSaveCompletion: (WorkInfoModel) -> Void
    }

    var dependencies: Dependencies
    private var workInfoState: StateWrapper<WorkInfoModel>
    private let disposeBag = DisposeBag()

    init(dependencies: Dependencies) {
        self.dependencies = dependencies
        self.workInfoState = StateWrapper<WorkInfoModel>(state: dependencies.workInfoEditing)
    }

    struct Input {
        let viewWillAppear: Signal<Void>
        let saveResume: Signal<Void>
        let companyNameText: Driver<String>
        let durationYearsOfExperience: Driver<Int>
    }

    struct ViewModel {
        let companyNameText: Driver<String>
        let allFieldValid: Driver<Bool>
        let durationYearsOfExperience: Driver<Int>
    }

    func createViewModel(_ input: Input) -> ViewModel {
        let companyNameText = input.companyNameText
            .do(onNext: {
                workInfoState.state.companyName = $0
            })
            .startWith(workInfoState.state.companyName)

        input.saveResume.asObservable()
            .subscribe(onNext: {
                dependencies.successSaveCompletion(workInfoState.state)
            })
            .disposed(by: disposeBag)

        let durationYearsOfExperience = input.durationYearsOfExperience
            .do(onNext: { durationYearsOfExperience in
                workInfoState.state.duration = durationYearsOfExperience
            })
            .startWith(workInfoState.state.duration)

        let companyNameValid = companyNameText.map({ $0.count > 0 }).asSignal(onErrorJustReturn: true)
        let allFieldValid = Signal.merge(companyNameValid)
            .startWith(false)

        return ViewModel(
            companyNameText: companyNameText,
            allFieldValid: allFieldValid.asDriver(onErrorJustReturn: true),
            durationYearsOfExperience: durationYearsOfExperience
        )
    }
}
