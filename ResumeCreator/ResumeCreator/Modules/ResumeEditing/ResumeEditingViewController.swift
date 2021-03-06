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


class ResumeEditingViewController: UIViewController {
    struct Dependencies {
        let viewModelFactory: ResumeEditingViewModelFactory
    }
    
    private let dependencies: Dependencies
    weak var coordinator: (Coordinator & WorkInfoAddingRoute & EducationDetailAddingRoute & ProjectDetailAddingRoute)?
    
    private lazy var barButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: nil, action: nil)
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()

        return scrollView
    }()
    private lazy var contentView: UIView = {
        let contentView = UIView()

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
    }()
    private lazy var selectedAvatarImage = PublishRelay<UIImage?>()
    
    // TODO: Refactoring
    // Need add validation for this field and validation for save button
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

    // TODO: Refactoring
    // Need add validation for this field and validation for save button
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

    // TODO: Refactoring
    // Need add Map/Location picker
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

    // TODO: Refactoring
    // Make multiline carreeObjectiveTextField
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

    // WorkSummary
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
    private let workSummaryTableView = WorkSummaryEmbedViewController()


    // skillsTableView
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
    private let skillsTableView = SkillsEmbedViewController()

    // Education Detail
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
    private let educationDetailTableView = EducationDetailEmbedViewController()

    // TODO: For refactoring
    // Same as work WorkSummary
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
    private let projectDetailTableView = ProjectDetailEmbedViewController()

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

        view.backgroundColor = .white

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

        addChild(workSummaryTableView)
        workSummaryTableView.view.translatesAutoresizingMaskIntoConstraints = false
        workSummaryTableView.didMove(toParent: self)

        contentView.addSubview(workSummaryTableView.view)
        workSummaryTableView.view.snp.makeConstraints { make in
            make.top.equalTo(workSummaryLabel.snp.bottom).offset(Constants.labelToTextOffset)
            make.leading.equalToSuperview().inset(Constants.leadingInset)
            make.trailing.equalToSuperview().inset(Constants.trailingInset)
        }

        // Skills - label + add button + tableview
        contentView.addSubview(skillsLabel)
        skillsLabel.snp.makeConstraints { make in
            make.top.equalTo(workSummaryTableView.view.snp.bottom).offset(Constants.moduleOffset)
            make.leading.equalToSuperview().inset(Constants.leadingInset)
        }

        contentView.addSubview(skillsAddButton)
        skillsAddButton.snp.makeConstraints { make in
            make.centerY.equalTo(skillsLabel.snp.centerY)
            make.leading.equalTo(skillsLabel.snp.trailing).offset(Constants.labelToAddImageOffset)
        }

        addChild(skillsTableView)
        skillsTableView.view.translatesAutoresizingMaskIntoConstraints = false
        skillsTableView.didMove(toParent: self)

        contentView.addSubview(skillsTableView.view)
        skillsTableView.view.snp.makeConstraints { make in
            make.top.equalTo(skillsAddButton.snp.bottom).offset(Constants.labelToTextOffset)
            make.leading.equalToSuperview().inset(Constants.leadingInset)
            make.trailing.equalToSuperview().inset(Constants.trailingInset)
        }

        
        // Education Detail - label + add button + tableview
        contentView.addSubview(educationDetailLabel)
        educationDetailLabel.snp.makeConstraints { make in
            make.top.equalTo(skillsTableView.view.snp.bottom).offset(Constants.moduleOffset)
            make.leading.equalToSuperview().inset(Constants.leadingInset)
        }
        
        contentView.addSubview(educationDetailAddButton)
        educationDetailAddButton.snp.makeConstraints { make in
            make.centerY.equalTo(educationDetailLabel.snp.centerY)
            make.leading.equalTo(educationDetailLabel.snp.trailing).offset(Constants.labelToAddImageOffset)
        }
        
        addChild(educationDetailTableView)
        educationDetailTableView.view.translatesAutoresizingMaskIntoConstraints = false
        educationDetailTableView.didMove(toParent: self)
        
        contentView.addSubview(educationDetailTableView.view)
        educationDetailTableView.view.snp.makeConstraints { make in
            make.top.equalTo(educationDetailAddButton.snp.bottom).offset(Constants.labelToTextOffset)
            make.leading.equalToSuperview().inset(Constants.leadingInset)
            make.trailing.equalToSuperview().inset(Constants.trailingInset)
        }

        // Project Detail - label + add button + tableview
        contentView.addSubview(projectDetailLabel)
        projectDetailLabel.snp.makeConstraints { make in
            make.top.equalTo(educationDetailTableView.view.snp.bottom).offset(Constants.moduleOffset)
            make.leading.equalToSuperview().inset(Constants.leadingInset)
        }
        
        contentView.addSubview(projectDetailAddButton)
        projectDetailAddButton.snp.makeConstraints { make in
            make.centerY.equalTo(projectDetailLabel.snp.centerY)
            make.leading.equalTo(projectDetailLabel.snp.trailing).offset(Constants.labelToAddImageOffset)
        }


        addChild(projectDetailTableView)
        projectDetailTableView.view.translatesAutoresizingMaskIntoConstraints = false
        projectDetailTableView.didMove(toParent: self)
        
        contentView.addSubview(projectDetailTableView.view)
        projectDetailTableView.view.snp.makeConstraints { make in
            make.top.equalTo(projectDetailAddButton.snp.bottom).offset(Constants.labelToTextOffset)
            make.leading.equalToSuperview().inset(Constants.leadingInset)
            make.trailing.equalToSuperview().inset(Constants.trailingInset)
            make.bottom.equalToSuperview().inset(Constants.bottomInsert)
        }
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
                selectSkill: skillsTableView.reactive.selectElement.asSignal(),
                deleteSkill: skillsTableView.reactive.deleteElement.asSignal(),
                addWorkInfo: workSummaryAddButton.rx.tap.asSignal(),
                selectWorkInfo: workSummaryTableView.reactive.selectElement.asSignal(),
                deleteWorkInfo: workSummaryTableView.reactive.deleteElement.asSignal(),
                addEducationDetail: educationDetailAddButton.rx.tap.asSignal(),
                selectEducationDetail: educationDetailTableView.reactive.selectElement.asSignal(),
                deleteEducationDetail: educationDetailTableView.reactive.deleteElement.asSignal(),
                addProjectDetail: projectDetailAddButton.rx.tap.asSignal(),
                selectProjectDetail: projectDetailTableView.reactive.selectElement.asSignal(),
                deleteProjectDetail: projectDetailTableView.reactive.deleteElement.asSignal()
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

        // Skills
        viewModel.skillsList.asObservable()
            .subscribe(onNext: { [weak self] skillsList in
                guard let self = self else { return }

                self.skillsTableView.setNewData(dataList: skillsList)
            })
            .disposed(by: disposeBag)

        // TODO: Better make something like skills cloud
        viewModel.skillEdit.asObservable()
            .subscribe(onNext: { [weak self] editSkillTuple in
                guard let self = self else { return }

                self.alertWithTextField(
                    title: "Skills",
                    message: "Change or write new skill",
                    placeholder: "Enter new skill...",
                    defaultText: editSkillTuple.0,
                    completion: editSkillTuple.1
                )
            })
            .disposed(by: disposeBag)

        // WorkInfo
        viewModel.workInfoList.asObservable()
            .subscribe(onNext: { [weak self] workInfoList in
                guard let self = self else { return }

                self.workSummaryTableView.setNewData(dataList: workInfoList)
            })
            .disposed(by: disposeBag)

        viewModel.workInfoEdit.asObservable()
            .subscribe(onNext: { [weak self] editWorkInfoTuple in
                guard let self = self else { return }

                self.coordinator?.workInfoAdding(workInfoEditing: editWorkInfoTuple.0, successCompletion: editWorkInfoTuple.1)
            })
            .disposed(by: disposeBag)

        // EducationDetail
        viewModel.educationDetailList.asObservable()
            .subscribe(onNext: { [weak self] educationDetailList in
                guard let self = self else { return }

                self.educationDetailTableView.setNewData(dataList: educationDetailList)
            })
            .disposed(by: disposeBag)

        viewModel.educationDetailEdit.asObservable()
            .subscribe(onNext: { [weak self] editEducationDetailTuple in
                guard let self = self else { return }

                self.coordinator?.educationDetailAdding(educationDetailEditing: editEducationDetailTuple.0, successCompletion: editEducationDetailTuple.1)
            })
            .disposed(by: disposeBag)

        // Project detail
        viewModel.projectDetailList.asObservable()
            .subscribe(onNext: { [weak self] projectDetailList in
                guard let self = self else { return }

                self.projectDetailTableView.setNewData(dataList: projectDetailList)
            })
            .disposed(by: disposeBag)

        viewModel.projectDetailEdit.asObservable()
            .subscribe(onNext: { [weak self] editEducationDetailTuple in
                guard let self = self else { return }

                self.coordinator?.projectDetailAdding(projectDetailEditing: editEducationDetailTuple.0, successCompletion: editEducationDetailTuple.1)
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

extension ResumeEditingViewController {
    public func alertWithTextField(title: String, message: String, placeholder: String, defaultText: String?, completion: @escaping ((String) -> Void)) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addTextField() { newTextField in
            newTextField.placeholder = placeholder
            newTextField.text = defaultText
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in })
        alert.addAction(UIAlertAction(title: "Change", style: .default) { action in
            if
                let textFields = alert.textFields,
                let firstTextField = textFields.first,
                let result = firstTextField.text
            {
                completion(result)
            }
        })
        navigationController?.present(alert, animated: true)
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
    static let bottomInsert: CGFloat = 50
}
