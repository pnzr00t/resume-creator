//
//  EducationDetailViewModel.swift
//  ResumeCreator
//
//  Created by Oleg Pustoshkin on 18.04.2022.
//

import RxCocoa
import RxSwift
import Foundation
import UIKit

struct EducationDetailViewModelFactory {
    struct Dependencies {
        let educationDetailEditing: EducationDetailModel
        let successSaveCompletion: (EducationDetailModel) -> Void
    }

    var dependencies: Dependencies
    private var educationDetailState: StateWrapper<EducationDetailModel>
    private let disposeBag = DisposeBag()

    init(dependencies: Dependencies) {
        self.dependencies = dependencies
        self.educationDetailState = StateWrapper<EducationDetailModel>(state: dependencies.educationDetailEditing)
    }

    struct Input {
        let viewWillAppear: Signal<Void>
        let saveResume: Signal<Void>
        let educationInstituteNameText: Driver<String>
        let datePicker: Signal<Date>
        let classPicker: Signal<Int>
        let percentagePicker: Signal<Int>
    }

    struct ViewModel {
        let allFieldValid: Driver<Bool>
        let educationInstituteNameText: Driver<String>
        let dateString: Driver<String>
        let classString: Driver<String>
        let percentageString: Driver<String>
    }

    func createViewModel(_ input: Input) -> ViewModel {
        let educationInstituteNameText = input.educationInstituteNameText
            .do(onNext: {
                educationDetailState.state.educationInstituteName = $0
            })
            .startWith(educationDetailState.state.educationInstituteName)

        input.saveResume.asObservable()
            .subscribe(onNext: {
                dependencies.successSaveCompletion(educationDetailState.state)
            })
            .disposed(by: disposeBag)
        
        let dateString = input.datePicker
            .do(onNext: {
                educationDetailState.state.passingYear = $0
            })
            .startWith(educationDetailState.state.passingYear)
            .map { date -> String in
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .medium
                dateFormatter.timeStyle = .none

                return dateFormatter.string(from: date)
            }
        
        let classString = input.classPicker
            .do(onNext: {
                educationDetailState.state.classEducation = $0
            })
            .startWith(educationDetailState.state.classEducation)
            .map { classInt -> String in

                return EducationDetailModel.ClassEducation(id: classInt).getString()
            }

        let percentageString = input.percentagePicker
            .do(onNext: {
                educationDetailState.state.percentage = $0
            })
            .startWith(educationDetailState.state.percentage)
            .map { percentage -> String in

                return "\(percentage)%"
            }

        let educationInstituteNameValid = educationInstituteNameText.map({ $0.count > 0 }).asSignal(onErrorJustReturn: true)
        let allFieldValid = Signal.merge(educationInstituteNameValid)
            .startWith(false)

        return ViewModel(
            allFieldValid: allFieldValid.asDriver(onErrorJustReturn: true),
            educationInstituteNameText: educationInstituteNameText,
            dateString: dateString.asDriver(onErrorJustReturn: ""),
            classString: classString.asDriver(onErrorJustReturn: ""),
            percentageString: percentageString.asDriver(onErrorJustReturn: "")
        )
    }
}
