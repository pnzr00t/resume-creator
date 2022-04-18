//
//  ResumeListViewModel.swift
//  ResumeCreator
//
//  Created by Oleg Pustoshkin on 18.04.2022.
//

import RxCocoa
import RxSwift
import UIKit
import SnapKit

struct ResumeListViewModelFactory {
    struct Dependencies {
        let resumeService: ResumeServiceProtocol
    }
    
    let dependencies: Dependencies
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    struct Input {
        let viewWillAppear: Signal<Void>
        let addButtonPressed: Signal<Void>
        let selectedResume: Signal<ResumeModel>
        let deleteResume: Signal<ResumeModel>
    }
    
    struct ViewModel {
        let cells: Signal<[ResumeModel]>
        let editResume: Signal<ResumeModel>
    }
    
    func createViewModel(_ input: Input) -> ViewModel {
        let deleteResume = input.deleteResume
            .do(onNext: { resumeToDelete in
                dependencies.resumeService.removeObject(resumeToDelete)
            })
            .map { _ in return Void() }
        
        let resumeList = Signal.merge(input.viewWillAppear, deleteResume)
            .flatMapLatest {
                Observable.just(dependencies.resumeService.getResumeList()).asSignal(onErrorJustReturn: [])
            }
        
        let addNewResumePressed = input.addButtonPressed.map { ResumeModel.createNewEmptyResume() }
        let editResume = Signal.merge(addNewResumePressed, input.selectedResume)
        return ViewModel(
            cells: resumeList,
            editResume: editResume
        )
    }
}
