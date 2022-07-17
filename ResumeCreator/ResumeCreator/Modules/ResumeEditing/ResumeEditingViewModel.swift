//
//  ResumeEditingViewModel.swift
//  ResumeCreator
//
//  Created by Oleg Pustoshkin on 18.04.2022.
//

import RxCocoa
import RxSwift
import RxGesture
import Foundation
import UIKit

struct ResumeEditingViewModelFactory {
    struct Dependencies {
        let editingResume: ResumeModel
        let resumeService: ResumeServiceProtocol
    }

    var dependencies: Dependencies
    private var resumeState: StateWrapper<ResumeModel>
    private var skillsUpdatePublisher = PublishRelay<Void>()
    private let disposeBag = DisposeBag()

    init(dependencies: Dependencies) {
        self.dependencies = dependencies
        self.resumeState = StateWrapper<ResumeModel>(state: dependencies.editingResume)
    }

    struct Input {
        let viewWillAppear: Signal<Void>
        let saveResume: Signal<Void>
        let resumeNameText: Driver<String>
        let selectedAvatarImage: Signal<UIImage?>
        let mobileNumberString: Driver<String>
        let emailAddress: Driver<String>
        let residenceAddress: Driver<String>
        let careerObjective: Driver<String>
        let totalYearsOfExperience: Driver<Int>

        let addSkill: Signal<Void>
        let selectSkill: Signal<IndexPath>
        let deleteSkill: Signal<IndexPath>

        let addWorkInfo: Signal<Void>
        let selectWorkInfo: Signal<IndexPath>
        let deleteWorkInfo: Signal<IndexPath>

        let addEducationDetail: Signal<Void>
        let selectEducationDetail: Signal<IndexPath>
        let deleteEducationDetail: Signal<IndexPath>

        let addProjectDetail: Signal<Void>
        let selectProjectDetail: Signal<IndexPath>
        let deleteProjectDetail: Signal<IndexPath>
    }

    struct ViewModel {
        let resumeNameText: Driver<String>
        let selectedImage: Signal<UIImage?>
        let mobileNumberString: Driver<String>
        let emailAddress: Driver<String>
        let residenceAddress: Driver<String>
        let careerObjective: Driver<String>

        let skillsList: Signal<[String]>
        let skillEdit: Signal<(String, (String) -> Void)>

        let workInfoList: Signal<[WorkInfoModel]>
        let workInfoEdit: Signal<(WorkInfoModel, (WorkInfoModel) -> Void)>

        let educationDetailList: Signal<[EducationDetailModel]>
        let educationDetailEdit: Signal<(EducationDetailModel, (EducationDetailModel) -> Void)>

        let projectDetailList: Signal<[ProjectDetailModel]>
        let projectDetailEdit: Signal<(ProjectDetailModel, (ProjectDetailModel) -> Void)>

        let allFieldValid: Driver<Bool>
        let totalYearsOfExperience: Driver<Int>
    }

    func createViewModel(_ input: Input) -> ViewModel {
        let resumeNameText = input.resumeNameText
            .do(onNext: {
                resumeState.state.resumeName = $0
            })
            .startWith(resumeState.state.resumeName)

        let startImage = resumeState.state.picture ?? UIImage(systemName: "face.smiling.fill")
        let selectedImage = input.selectedAvatarImage
            .do(onNext: { avatarImage in
                resumeState.state.picture = avatarImage
            })
            .startWith(startImage)
            

        let mobileNumberString = input.mobileNumberString
            .do(onNext: {
                resumeState.state.mobileNumberString = $0
            })
            .startWith(resumeState.state.mobileNumberString)

        let emailAddress = input.emailAddress
            .do(onNext: {
                resumeState.state.emailAddress = $0
            })
            .startWith(resumeState.state.emailAddress)


        let residenceAddress = input.residenceAddress
            .do(onNext: {
                resumeState.state.residenceAddress = $0
            })
            .startWith(resumeState.state.residenceAddress)

        let careerObjective = input.careerObjective
            .do(onNext: {
                resumeState.state.careerObjective = $0
            })
            .startWith(resumeState.state.careerObjective)

        let totalYearsOfExperience = input.totalYearsOfExperience
            .do(onNext: { totalYearsOfExperience in
                resumeState.state.totalYearsOfExperience = totalYearsOfExperience
            })
            .startWith(resumeState.state.totalYearsOfExperience)


        input.saveResume.asObservable()
            .subscribe(onNext: {
                // Save resume, get new resume model (id change from new -> existence(UUID))
                if let editedResume = dependencies.resumeService.editResume(resumeState.state) {
                    resumeState.state = editedResume
                }
            })
            .disposed(by: disposeBag)

        
        // Skills
        let deleteSkill = input.deleteSkill
            .do(onNext: { indexPath in
                resumeState.state.skillsList.remove(at: indexPath.row)
            })
            .map { _ in return Void() }

        let skillsList = Signal.merge(input.viewWillAppear, deleteSkill, skillsUpdatePublisher.asSignal())
            .flatMapLatest {
                Observable.just(resumeState.state.skillsList).asSignal(onErrorJustReturn: [])
            }

        let addSkillChain = input.addSkill.map { _ -> (String, (String) -> Void) in
            return (
                "",
                { newSkill in
                    resumeState.state.skillsList.append(newSkill)
                    skillsUpdatePublisher.accept(Void())
                }
            )
        }
        let editSkillChain = input.selectSkill.map { indexPath -> (String, (String) -> Void) in
            let selectedSkill = resumeState.state.skillsList[indexPath.row]
            return (
                selectedSkill,
                { editedSkill in
                    resumeState.state.skillsList[indexPath.row] = editedSkill
                    skillsUpdatePublisher.accept(Void())
                }
            )
        }
        let skillEdit = Signal.merge(addSkillChain, editSkillChain)


        // Work Info
        let deleteWorkInfo = input.deleteWorkInfo
            .do(onNext: { indexPath in
                resumeState.state.workSummaryList.remove(at: indexPath.row)
            })
            .map { _ in return Void() }

        let workInfoList = Signal.merge(input.viewWillAppear, deleteWorkInfo)
            .flatMapLatest {
                Observable.just(resumeState.state.workSummaryList).asSignal(onErrorJustReturn: [])
            }

        let addWorkInfoChain = input.addWorkInfo.map { _ -> (WorkInfoModel, (WorkInfoModel) -> Void) in
            return (
                WorkInfoModel.createNewEmptyWorkInfo(),
                { newWorkInfo in
                    resumeState.state.workSummaryList.append(newWorkInfo)
                }
            )
        }
        let editWorkInfoChain = input.selectWorkInfo.map { indexPath -> (WorkInfoModel, (WorkInfoModel) -> Void) in
            let selectedWorkInfo = resumeState.state.workSummaryList[indexPath.row]
            return (
                selectedWorkInfo,
                { editedWorkInfo in
                    resumeState.state.workSummaryList[indexPath.row] = editedWorkInfo
                }
            )
        }
        let workInfoEdit = Signal.merge(addWorkInfoChain, editWorkInfoChain)


        // Education list
        let deleteEducationList = input.deleteEducationDetail
            .do(onNext: { indexPath in
                resumeState.state.educationDetailList.remove(at: indexPath.row)
            })
            .map { _ in return Void() }

        let educationDetailList = Signal.merge(input.viewWillAppear, deleteEducationList)
            .flatMapLatest {
                Observable.just(resumeState.state.educationDetailList).asSignal(onErrorJustReturn: [])
            }

        let addEducationDetailChain = input.addEducationDetail.map { _ -> (EducationDetailModel, (EducationDetailModel) -> Void) in
            return (
                EducationDetailModel.createNewEmptyEducationDetail(),
                { newEducationDetail in
                    resumeState.state.educationDetailList.append(newEducationDetail)
                }
            )
        }
        let editEducationDetailChain = input.selectEducationDetail.map { indexPath -> (EducationDetailModel, (EducationDetailModel) -> Void) in
            let selectedEducationDetail = resumeState.state.educationDetailList[indexPath.row]
            return (
                selectedEducationDetail,
                { editedEducationDetail in
                    resumeState.state.educationDetailList[indexPath.row] = editedEducationDetail
                }
            )
        }
        let educationDetailEdit = Signal.merge(addEducationDetailChain, editEducationDetailChain)


        // Project Detail
        let deleteProjectDetail = input.deleteProjectDetail
            .do(onNext: { indexPath in
                resumeState.state.projectDetailList.remove(at: indexPath.row)
            })
            .map { _ in return Void() }

        let projectDetailList = Signal.merge(input.viewWillAppear, deleteProjectDetail)
            .flatMapLatest {
                Observable.just(resumeState.state.projectDetailList).asSignal(onErrorJustReturn: [])
            }
        
        let addProjectDetailChain = input.addProjectDetail.map { _ -> (ProjectDetailModel, (ProjectDetailModel) -> Void) in
            return (
                ProjectDetailModel.createNewEmptyProjectDetail(),
                { newProjectDetail in
                    resumeState.state.projectDetailList.append(newProjectDetail)
                }
            )
        }
        let editProjectDetailChain = input.selectProjectDetail.map { indexPath -> (ProjectDetailModel, (ProjectDetailModel) -> Void) in
            let selectedProjectDetail = resumeState.state.projectDetailList[indexPath.row]
            return (
                selectedProjectDetail,
                { editedProjectDetail in
                    resumeState.state.projectDetailList[indexPath.row] = editedProjectDetail
                }
            )
        }
        let projectDetailEdit = Signal.merge(addProjectDetailChain, editProjectDetailChain)


        let resumeNameValid = input.resumeNameText.map({ $0.count > 0 }).asSignal(onErrorJustReturn: true)
        let allFieldValid = Signal.merge(resumeNameValid)
            .startWith(false)

        return ViewModel(
            resumeNameText: resumeNameText,
            selectedImage: selectedImage,
            mobileNumberString: mobileNumberString,
            emailAddress: emailAddress,
            residenceAddress: residenceAddress,
            careerObjective: careerObjective,
            skillsList: skillsList,
            skillEdit: skillEdit,
            workInfoList: workInfoList,
            workInfoEdit: workInfoEdit,
            educationDetailList: educationDetailList,
            educationDetailEdit: educationDetailEdit,
            projectDetailList: projectDetailList,
            projectDetailEdit: projectDetailEdit,
            allFieldValid: allFieldValid.asDriver(onErrorJustReturn: true),
            totalYearsOfExperience: totalYearsOfExperience
        )
    }
}
