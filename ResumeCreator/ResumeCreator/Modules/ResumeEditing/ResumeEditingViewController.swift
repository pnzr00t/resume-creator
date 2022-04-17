//
//  ResumeEditingViewController.swift
//  ResumeCreator
//
//  Created by Oleg Pustoshkin on 14.04.2022.
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
        let workInfoList: Signal<[WorkInfoModel]>
        let educationDetailList: Signal<[EducationDetailModel]>
        let projectDetailList: Signal<[ProjectDetailModel]>
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

        let skillsList = Signal.merge(input.viewWillAppear, deleteSkill)
            .flatMapLatest {
                Observable.just(resumeState.state.skillsList).asSignal(onErrorJustReturn: [])
            }

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

        // Project Detail
        let deleteProjectDetail = input.deleteEducationDetail
            .do(onNext: { indexPath in
                resumeState.state.projectDetailList.remove(at: indexPath.row)
            })
            .map { _ in return Void() }

        let projectDetailList = Signal.merge(input.viewWillAppear, deleteProjectDetail)
            .flatMapLatest {
                Observable.just(resumeState.state.projectDetailList).asSignal(onErrorJustReturn: [])
            }


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
            workInfoList: workInfoList,
            educationDetailList: educationDetailList,
            projectDetailList: projectDetailList,
            allFieldValid: allFieldValid.asDriver(onErrorJustReturn: true),
            totalYearsOfExperience: totalYearsOfExperience
        )
    }
}

class ResumeEditingViewController: UIViewController {
    struct Dependencies {
        let viewModelFactory: ResumeEditingViewModelFactory
    }
    
    private let dependencies: Dependencies
    weak var coordinator: (Coordinator & WorkInfoAddingRoute & EducationDetailAddingRoute & ProjectDetailAddingRoute)?
    
    private lazy var barButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: nil, action: nil)
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        //scrollView.backgroundColor = .red
        return scrollView
    }()
    private lazy var contentView: UIView = {
        let contentView = UIView()
        //contentView.backgroundColor = .blue
        return contentView
    }()
    
    private lazy var resumeNameLabel: UILabel = {
        let label = UILabel()
        label.text = "Resume name"
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    lazy var resumeNameTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Enter resume name..."
        textField.keyboardType = UIKeyboardType.default
        textField.returnKeyType = UIReturnKeyType.done
        textField.autocorrectionType = UITextAutocorrectionType.no
        textField.font = UIFont.systemFont(ofSize: 13)
        textField.borderStyle = UITextField.BorderStyle.roundedRect
        textField.clearButtonMode = UITextField.ViewMode.whileEditing;
        textField.contentVerticalAlignment = UIControl.ContentVerticalAlignment.center
        return textField
    }()
    
    private lazy var avatarImageLabel: UILabel = {
        let label = UILabel()
        label.text = "Choice avatar"
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    private lazy var avatarImage: UIImageView = {
        UIImageView(image: UIImage(systemName: "face.smiling.fill"))
        
        /*image.layer.borderWidth = 1
         image.layer.masksToBounds = false
         image.layer.borderColor = UIColor.black.cgColor
         image.layer.cornerRadius = avatarImageSize.width/2
         image.clipsToBounds = true*/
    }()
    private lazy var selectedAvatarImage = PublishRelay<UIImage?>()
    
    private lazy var mobileNumberLabel: UILabel = {
        let label = UILabel()
        label.text = "Mobile number"
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    private lazy var mobileNumberTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Enter you mobile number"
        textField.keyboardType = UIKeyboardType.phonePad
        textField.returnKeyType = UIReturnKeyType.done
        textField.autocorrectionType = UITextAutocorrectionType.no
        textField.font = UIFont.systemFont(ofSize: 13)
        textField.borderStyle = UITextField.BorderStyle.roundedRect
        textField.clearButtonMode = UITextField.ViewMode.whileEditing;
        textField.contentVerticalAlignment = UIControl.ContentVerticalAlignment.center
        return textField
    }()

    private lazy var emailAddressLabel: UILabel = {
        let label = UILabel()
        label.text = "Email Address"
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    private lazy var emailAddressTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Enter you email address"
        textField.keyboardType = UIKeyboardType.phonePad
        textField.returnKeyType = UIReturnKeyType.done
        textField.autocorrectionType = UITextAutocorrectionType.no
        textField.font = UIFont.systemFont(ofSize: 13)
        textField.borderStyle = UITextField.BorderStyle.roundedRect
        textField.clearButtonMode = UITextField.ViewMode.whileEditing;
        textField.contentVerticalAlignment = UIControl.ContentVerticalAlignment.center
        return textField
    }()

    private lazy var residenceAddressLabel: UILabel = {
        let label = UILabel()
        label.text = "Residence Address"
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    private lazy var residenceAddressTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Enter you address"
        textField.keyboardType = UIKeyboardType.default
        textField.returnKeyType = UIReturnKeyType.done
        textField.autocorrectionType = UITextAutocorrectionType.no
        textField.font = UIFont.systemFont(ofSize: 13)
        textField.borderStyle = UITextField.BorderStyle.roundedRect
        textField.clearButtonMode = UITextField.ViewMode.whileEditing;
        textField.contentVerticalAlignment = UIControl.ContentVerticalAlignment.center
        return textField
    }()
    
    private lazy var careerObjectiveLabel: UILabel = {
        let label = UILabel()
        label.text = "Career Objective"
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    private lazy var careerObjectiveTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Enter you Career Objectives"
        textField.keyboardType = UIKeyboardType.default
        textField.returnKeyType = UIReturnKeyType.done
        textField.autocorrectionType = UITextAutocorrectionType.no
        textField.font = UIFont.systemFont(ofSize: 13)
        textField.borderStyle = UITextField.BorderStyle.roundedRect
        textField.clearButtonMode = UITextField.ViewMode.whileEditing;
        textField.contentVerticalAlignment = UIControl.ContentVerticalAlignment.center
        return textField
    }()
    
    private lazy var totalYearsOfExperienceLabel: UILabel = {
        let label = UILabel()
        label.text = "Total Years of experience"
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    private lazy var totalYearsOfExperienceStepper: UIStepper = {
        let stepper = UIStepper()
        stepper.minimumValue = 0
        stepper.maximumValue = 70
        stepper.stepValue = 1
        stepper.value = 0
        return stepper
    }()
    private lazy var totalYearsOfExperienceValueLabel: UILabel = {
        let label = UILabel()
        label.text = "0"
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    
    private lazy var workSummaryLabel: UILabel = {
        let label = UILabel()
        label.text = "Work Summary"
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    private lazy var workSummaryAddButton: UIButton = {
        let addButton = UIButton()
        addButton.setImage(UIImage(systemName: "plus.app.fill"), for: .normal)
        return addButton
    }()
    private lazy var workSummaryTableView: SelfSizedTableView = {
        let selfSizedTableView = SelfSizedTableView()
        return selfSizedTableView
    }()
    private let selectWorkSummaryPublisher = PublishRelay<IndexPath>()
    private let deleteWorkSummaryPublisher = PublishRelay<IndexPath>()
    private var workInfoList = [WorkInfoModel]()


    private lazy var skillsLabel: UILabel = {
        let label = UILabel()
        label.text = "Skills"
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    private lazy var skillsAddButton: UIButton = {
        let addButton = UIButton()
        addButton.setImage(UIImage(systemName: "plus.app.fill"), for: .normal)
        return addButton
    }()
    private lazy var skillsTableView: SelfSizedTableView = {
        let selfSizedTableView = SelfSizedTableView()
        return selfSizedTableView
    }()
    private let selectSkillsPublisher = PublishRelay<IndexPath>()
    private let deleteSkillsPublisher = PublishRelay<IndexPath>()
    private var skillsList = [String]()

    private lazy var educationDetailLabel: UILabel = {
        let label = UILabel()
        label.text = "Education Details"
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    private lazy var educationDetailAddButton: UIButton = {
        let addButton = UIButton()
        addButton.setImage(UIImage(systemName: "plus.app.fill"), for: .normal)
        return addButton
    }()
    private lazy var educationDetailTableView: SelfSizedTableView = {
        let selfSizedTableView = SelfSizedTableView()
        return selfSizedTableView
    }()
    private let selectEducationDetailPublisher = PublishRelay<IndexPath>()
    private let deleteEducationDetailPublisher = PublishRelay<IndexPath>()
    private var educationDetailList = [EducationDetailModel]()

    private lazy var projectDetailLabel: UILabel = {
        let label = UILabel()
        label.text = "Project Details"
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    private lazy var projectDetailAddButton: UIButton = {
        let addButton = UIButton()
        addButton.setImage(UIImage(systemName: "plus.app.fill"), for: .normal)
        return addButton
    }()
    private lazy var projectDetailTableView: SelfSizedTableView = {
        let selfSizedTableView = SelfSizedTableView()
        return selfSizedTableView
    }()
    private let selectProjectDetailPublisher = PublishRelay<IndexPath>()
    private let deleteProjectDetailPublisher = PublishRelay<IndexPath>()
    private var projectDetailList = [ProjectDetailModel]()

    private let cellReuseIdentifier = "cell"

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
        tableViewIniting()
        setupBindings()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        coordinator?.viewDidDisappear()
    }
    
    private func commonInit() {
        navigationItem.rightBarButtonItem = barButtonItem
        
        title = "Editing resume"
        
        view.addSubview(scrollView)
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.snp.makeConstraints { make in
            make.top.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
            
        }
        // ContentWidth == SuperViewWidth
        scrollView.contentLayoutGuide.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor).isActive = true
        
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
        }
        
        // Resume name
        contentView.addSubview(resumeNameLabel)
        resumeNameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(Constants.topInset)
            make.leading.equalToSuperview().inset(Constants.leadingInset)
        }
        
        contentView.addSubview(resumeNameTextField)
        resumeNameTextField.snp.makeConstraints { make in
            make.top.equalTo(resumeNameLabel.snp.bottom).offset(Constants.labelToTextOffset)
            make.leading.equalToSuperview().inset(Constants.leadingInset)
            make.trailing.equalToSuperview().inset(Constants.trailingInset)
        }
        
        // Avatar image
        contentView.addSubview(avatarImageLabel)
        avatarImageLabel.snp.makeConstraints { make in
            make.top.equalTo(resumeNameTextField.snp.bottom).offset(Constants.moduleOffset)
            make.leading.equalToSuperview().inset(Constants.leadingInset)
        }
        
        contentView.addSubview(avatarImage)
        avatarImage.snp.makeConstraints { make in
            make.top.equalTo(avatarImageLabel.snp.bottom).offset(Constants.labelToTextOffset)
            make.leading.equalToSuperview().inset(Constants.leadingInset)
            make.size.equalTo(Constants.avatarImageSize)
        }

        // Mobile number
        contentView.addSubview(mobileNumberLabel)
        mobileNumberLabel.snp.makeConstraints { make in
            make.top.equalTo(avatarImage.snp.bottom).offset(Constants.moduleOffset)
            make.leading.equalToSuperview().inset(Constants.leadingInset)
        }
        
        contentView.addSubview(mobileNumberTextField)
        mobileNumberTextField.snp.makeConstraints { make in
            make.top.equalTo(mobileNumberLabel.snp.bottom).offset(Constants.labelToTextOffset)
            make.leading.equalToSuperview().inset(Constants.leadingInset)
            make.trailing.equalToSuperview().inset(Constants.trailingInset)
        }

        // Email address
        contentView.addSubview(emailAddressLabel)
        emailAddressLabel.snp.makeConstraints { make in
            make.top.equalTo(mobileNumberTextField.snp.bottom).offset(Constants.moduleOffset)
            make.leading.equalToSuperview().inset(Constants.leadingInset)
        }
        
        contentView.addSubview(emailAddressTextField)
        emailAddressTextField.snp.makeConstraints { make in
            make.top.equalTo(emailAddressLabel.snp.bottom).offset(Constants.labelToTextOffset)
            make.leading.equalToSuperview().inset(Constants.leadingInset)
            make.trailing.equalToSuperview().inset(Constants.trailingInset)
        }

        // Residence Address
        contentView.addSubview(residenceAddressLabel)
        residenceAddressLabel.snp.makeConstraints { make in
            make.top.equalTo(emailAddressTextField.snp.bottom).offset(Constants.moduleOffset)
            make.leading.equalToSuperview().inset(Constants.leadingInset)
        }

        contentView.addSubview(residenceAddressTextField)
        residenceAddressTextField.snp.makeConstraints { make in
            make.top.equalTo(residenceAddressLabel.snp.bottom).offset(Constants.labelToTextOffset)
            make.leading.equalToSuperview().inset(Constants.leadingInset)
            make.trailing.equalToSuperview().inset(Constants.trailingInset)
            
        }

        // Career Objective
        contentView.addSubview(careerObjectiveLabel)
        careerObjectiveLabel.snp.makeConstraints { make in
            make.top.equalTo(residenceAddressTextField.snp.bottom).offset(Constants.moduleOffset)
            make.leading.equalToSuperview().inset(Constants.leadingInset)
        }
        
        contentView.addSubview(careerObjectiveTextField)
        careerObjectiveTextField.snp.makeConstraints { make in
            make.top.equalTo(careerObjectiveLabel.snp.bottom).offset(Constants.labelToTextOffset)
            make.leading.equalToSuperview().inset(Constants.leadingInset)
            make.trailing.equalToSuperview().inset(Constants.trailingInset)
        }
        
        // Total years of experience label + stepper + tableView
        contentView.addSubview(totalYearsOfExperienceLabel)
        totalYearsOfExperienceLabel.snp.makeConstraints { make in
            make.top.equalTo(careerObjectiveTextField.snp.bottom).offset(Constants.moduleOffset)
            make.leading.equalToSuperview().inset(Constants.leadingInset)
        }
        
        contentView.addSubview(totalYearsOfExperienceStepper)
        totalYearsOfExperienceStepper.snp.makeConstraints { make in
            make.top.equalTo(totalYearsOfExperienceLabel.snp.bottom).offset(Constants.labelToTextOffset)
            make.leading.equalToSuperview().inset(Constants.leadingInset)
            //make.trailing.equalToSuperview().inset(Constants.trailingInset)
        }
        
        contentView.addSubview(totalYearsOfExperienceValueLabel)
        totalYearsOfExperienceValueLabel.snp.makeConstraints { make in
            make.centerY.equalTo(totalYearsOfExperienceStepper.snp.centerY)
            make.leading.equalTo(totalYearsOfExperienceStepper.snp.trailing).offset(Constants.stepperToLabelValueOffset)
        }
        
        // workSummary - label + add button + tableview
        contentView.addSubview(workSummaryLabel)
        workSummaryLabel.snp.makeConstraints { make in
            make.top.equalTo(totalYearsOfExperienceStepper.snp.bottom).offset(Constants.moduleOffset)
            make.leading.equalToSuperview().inset(Constants.leadingInset)
        }
        
        contentView.addSubview(workSummaryAddButton)
        workSummaryAddButton.snp.makeConstraints { make in
            make.centerY.equalTo(workSummaryLabel.snp.centerY)
            make.leading.equalTo(workSummaryLabel.snp.trailing).offset(Constants.labelToAddImageOffset)
        }
        
        contentView.addSubview(workSummaryTableView)
        workSummaryTableView.snp.makeConstraints { make in
            make.top.equalTo(workSummaryLabel.snp.bottom).offset(Constants.labelToTextOffset)
            make.leading.equalToSuperview().inset(Constants.leadingInset)
            make.trailing.equalToSuperview().inset(Constants.trailingInset)
        }
        
        // Skills - label + add button + tableview
        contentView.addSubview(skillsLabel)
        skillsLabel.snp.makeConstraints { make in
            make.top.equalTo(workSummaryTableView.snp.bottom).offset(Constants.moduleOffset)
            make.leading.equalToSuperview().inset(Constants.leadingInset)
        }
        
        contentView.addSubview(skillsAddButton)
        skillsAddButton.snp.makeConstraints { make in
            make.centerY.equalTo(skillsLabel.snp.centerY)
            make.leading.equalTo(skillsLabel.snp.trailing).offset(Constants.labelToAddImageOffset)
        }

        contentView.addSubview(skillsTableView)
        skillsTableView.snp.makeConstraints { make in
            make.top.equalTo(skillsAddButton.snp.bottom).offset(Constants.labelToTextOffset)
            make.leading.equalToSuperview().inset(Constants.leadingInset)
            make.trailing.equalToSuperview().inset(Constants.trailingInset)
        }

        // educationDetail - label + add button + tableview
        contentView.addSubview(projectDetailLabel)
        projectDetailLabel.snp.makeConstraints { make in
            make.top.equalTo(skillsTableView.snp.bottom).offset(Constants.moduleOffset)
            make.leading.equalToSuperview().inset(Constants.leadingInset)
        }
        
        contentView.addSubview(projectDetailAddButton)
        projectDetailAddButton.snp.makeConstraints { make in
            make.centerY.equalTo(projectDetailLabel.snp.centerY)
            make.leading.equalTo(projectDetailLabel.snp.trailing).offset(Constants.labelToAddImageOffset)
        }
        
        contentView.addSubview(projectDetailTableView)
        projectDetailTableView.snp.makeConstraints { make in
            make.top.equalTo(projectDetailAddButton.snp.bottom).offset(Constants.labelToTextOffset)
            make.leading.equalToSuperview().inset(Constants.leadingInset)
            make.trailing.equalToSuperview().inset(Constants.trailingInset)
            //make.bottom.equalToSuperview().inset(16)
        }
        
        // FIXME: DELETE THIS
        let bottomView = UIView()
        bottomView.backgroundColor = .white
        contentView.addSubview(bottomView)
        bottomView.snp.makeConstraints { make in
            make.top.equalTo(projectDetailTableView.snp.bottom).offset(Constants.moduleOffset)
            make.leading.equalToSuperview().inset(Constants.leadingInset)
            make.trailing.equalToSuperview().inset(Constants.trailingInset)
            make.height.equalTo(100)
            make.bottom.equalToSuperview().inset(16)
        }
    }

    private func tableViewIniting() {
        workSummaryTableView.delegate = self
        skillsTableView.delegate = self
        projectDetailTableView.delegate = self
        educationDetailTableView.delegate = self

        workSummaryTableView.dataSource = self
        skillsTableView.dataSource = self
        projectDetailTableView.dataSource = self
        educationDetailTableView.dataSource = self
        
        workSummaryTableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        skillsTableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        projectDetailTableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        educationDetailTableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
    }

    private func setupBindings() {
        let viewModel = dependencies.viewModelFactory.createViewModel(
            ResumeEditingViewModelFactory.Input(
                viewWillAppear: rx.viewWillAppear.asSignal(),
                saveResume: barButtonItem.rx.tap.asSignal(),
                resumeNameText: resumeNameTextField.rx.text.compactMap { $0 }.asDriver(onErrorJustReturn: ""),
                selectedAvatarImage: selectedAvatarImage.asSignal(),
                mobileNumberString: mobileNumberTextField.rx.text.compactMap { $0 }.asDriver(onErrorJustReturn: ""),
                emailAddress: emailAddressTextField.rx.text.compactMap { $0 }.asDriver(onErrorJustReturn: ""),
                residenceAddress: residenceAddressTextField.rx.text.compactMap { $0 }.asDriver(onErrorJustReturn: ""),
                careerObjective: careerObjectiveTextField.rx.text.compactMap { $0 }.asDriver(onErrorJustReturn: ""),
                totalYearsOfExperience: totalYearsOfExperienceStepper.rx.value.map { Int($0) }.asDriver(onErrorJustReturn: 0),
                addSkill: skillsAddButton.rx.tap.asSignal(),
                selectSkill: selectSkillsPublisher.asSignal(),
                deleteSkill: deleteSkillsPublisher.asSignal(),
                addWorkInfo: workSummaryAddButton.rx.tap.asSignal(),
                selectWorkInfo: selectWorkSummaryPublisher.asSignal(),
                deleteWorkInfo: deleteWorkSummaryPublisher.asSignal(),
                addEducationDetail: educationDetailAddButton.rx.tap.asSignal(),
                selectEducationDetail: selectEducationDetailPublisher.asSignal(),
                deleteEducationDetail: deleteEducationDetailPublisher.asSignal(),
                addProjectDetail: projectDetailAddButton.rx.tap.asSignal(),
                selectProjectDetail: selectProjectDetailPublisher.asSignal(),
                deleteProjectDetail: deleteProjectDetailPublisher.asSignal()
            )
        )
        
        viewModel.resumeNameText.asObservable()
            .subscribe(onNext: { [weak self] text in
                guard let self = self else { return }

                self.resumeNameTextField.text = text
            })
            .disposed(by: disposeBag)

        viewModel.selectedImage.asObservable()
            .subscribe(onNext: { [weak self] selectedImage in
                guard let self = self else { return }

                self.avatarImage.image = selectedImage
            })
            .disposed(by: disposeBag)

        viewModel.mobileNumberString.asObservable()
            .subscribe(onNext: { [weak self] text in
                guard let self = self else { return }

                self.mobileNumberTextField.text = text
            })
            .disposed(by: disposeBag)
        
        viewModel.emailAddress.asObservable()
            .subscribe(onNext: { [weak self] text in
                guard let self = self else { return }

                self.emailAddressTextField.text = text
            })
            .disposed(by: disposeBag)
    
        viewModel.residenceAddress.asObservable()
            .subscribe(onNext: { [weak self] text in
                guard let self = self else { return }

                self.residenceAddressTextField.text = text
            })
            .disposed(by: disposeBag)

        viewModel.careerObjective.asObservable()
            .subscribe(onNext: { [weak self] text in
                guard let self = self else { return }

                self.careerObjectiveTextField.text = text
            })
            .disposed(by: disposeBag)

        viewModel.allFieldValid
            .drive(onNext: { [weak self] isValid in
                guard let self = self else { return }

                self.barButtonItem.isEnabled = isValid
            })
            .disposed(by: disposeBag)

        // Stepper init
        viewModel.totalYearsOfExperience
            .take(1)
            .drive(onNext: { [weak self] totalYearsOfExperience in
                guard let self = self else { return }

                self.totalYearsOfExperienceStepper.value = Double(totalYearsOfExperience)
            })
            .disposed(by: disposeBag)

        viewModel.totalYearsOfExperience
            .drive(onNext: { [weak self] totalYearsOfExperience in
                guard let self = self else { return }

                self.totalYearsOfExperienceValueLabel.text = "\(totalYearsOfExperience)"
            })
            .disposed(by: disposeBag)

        viewModel.skillsList.asObservable()
            .subscribe(onNext: { [weak self] skillsList in
                guard let self = self else { return }

                self.skillsList = skillsList
            })
            .disposed(by: disposeBag)

        viewModel.workInfoList.asObservable()
            .subscribe(onNext: { [weak self] workInfoList in
                guard let self = self else { return }

                self.workInfoList = workInfoList
            })
            .disposed(by: disposeBag)

        viewModel.educationDetailList.asObservable()
            .subscribe(onNext: { [weak self] educationDetailList in
                guard let self = self else { return }

                self.educationDetailList = educationDetailList
            })
            .disposed(by: disposeBag)

        viewModel.projectDetailList.asObservable()
            .subscribe(onNext: { [weak self] projectDetailList in
                guard let self = self else { return }

                self.projectDetailList = projectDetailList
            })
            .disposed(by: disposeBag)

        avatarImage.rx.tapGesture()
            .when(.recognized)
            .asObservable()
            .subscribe(onNext: { [weak self] projectDetailList in
                guard let self = self else { return }

                self.showImagePicker()
            })
            .disposed(by: disposeBag)
    }
}

extension ResumeEditingViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }

        selectedAvatarImage.accept(image)

        dismiss(animated: true)
    }

    func showImagePicker() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
}

extension ResumeEditingViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        false
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    }
}

extension ResumeEditingViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        5
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reusableCell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath)
        reusableCell.textLabel?.text = "Hello world \(indexPath.row)"
        
        return reusableCell
    }
}
/*extension ResumeListViewController: UITableViewDelegate {
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
}*/

fileprivate enum Constants {
    static let topInset: CGFloat = 16
    static let leadingInset: CGFloat = 8
    static let trailingInset: CGFloat = 8
    static let labelToTextOffset: CGFloat = 6
    
    static let moduleOffset: CGFloat = 16
    
    static let avatarImageSize: CGSize = CGSize(width: 100, height: 100)
    
    static let stepperToLabelValueOffset: CGFloat = 16
    
    static let addImageSize: CGSize = CGSize(width: 24, height: 24)
    static let labelToAddImageOffset: CGFloat = 16
}
