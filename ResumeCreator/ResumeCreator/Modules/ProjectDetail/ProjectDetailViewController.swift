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

// Constraints error for TUISystemInputAssistantView
// I find this "This is Apple's bug, not yours. Ignore it. It's a widespread "issue"
// but there's nothing to be done about it; no visual harm is registered. It's just an annoying console dump"
class ProjectDetailViewController: UIViewController {
    struct Dependencies {
        let viewModelFactory: ProjectDetailViewModelFactory
    }
    
    private let dependencies: Dependencies
    weak var coordinator: ProjectDetailCoordinator?

    private lazy var barButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: nil, action: nil)

    private let disposeBag = DisposeBag()
    
    private lazy var contentView: UIView = {
        let contentView = UIView()
        //contentView.backgroundColor = .blue
        return contentView
    }()

    /// Project name
    private lazy var projectNameLabel: UILabel = {
        let label = UILabel()
        label.text = "Company Name"
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    lazy var projectNameTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Enter Company Name..."
        textField.keyboardType = UIKeyboardType.default
        textField.returnKeyType = UIReturnKeyType.done
        textField.autocorrectionType = UITextAutocorrectionType.no
        textField.font = UIFont.systemFont(ofSize: 13)
        textField.borderStyle = UITextField.BorderStyle.roundedRect
        textField.clearButtonMode = UITextField.ViewMode.whileEditing;
        textField.contentVerticalAlignment = UIControl.ContentVerticalAlignment.center
        return textField
    }()

    /// Team size
    private lazy var teamSizeLabel: UILabel = {
        let label = UILabel()
        label.text = "Total years of experience"
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    private lazy var teamSizeStepper: UIStepper = {
        let stepper = UIStepper()
        stepper.minimumValue = 0
        stepper.maximumValue = 70
        stepper.stepValue = 1
        stepper.value = 0
        return stepper
    }()
    private lazy var teamSizeValueLabel: UILabel = {
        let label = UILabel()
        label.text = "0"
        label.font = .systemFont(ofSize: 16)
        return label
    }()

    /// Project summary
    private lazy var projectSummaryLabel: UILabel = {
        let label = UILabel()
        label.text = "Project summary"
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    lazy var projectSummaryTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Enter Project Summary..."
        textField.keyboardType = UIKeyboardType.default
        textField.returnKeyType = UIReturnKeyType.done
        textField.autocorrectionType = UITextAutocorrectionType.no
        textField.font = UIFont.systemFont(ofSize: 13)
        textField.borderStyle = UITextField.BorderStyle.roundedRect
        textField.clearButtonMode = UITextField.ViewMode.whileEditing;
        textField.contentVerticalAlignment = UIControl.ContentVerticalAlignment.center
        return textField
    }()

    /// Technology used
    private lazy var technologyUsedLabel: UILabel = {
        let label = UILabel()
        label.text = "Technology used"
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    lazy var technologyUsedTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Enter Technology Used..."
        textField.keyboardType = UIKeyboardType.default
        textField.returnKeyType = UIReturnKeyType.done
        textField.autocorrectionType = UITextAutocorrectionType.no
        textField.font = UIFont.systemFont(ofSize: 13)
        textField.borderStyle = UITextField.BorderStyle.roundedRect
        textField.clearButtonMode = UITextField.ViewMode.whileEditing;
        textField.contentVerticalAlignment = UIControl.ContentVerticalAlignment.center
        return textField
    }()

    /// Role in project
    private lazy var roleLabel: UILabel = {
        let label = UILabel()
        label.text = "Role"
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    lazy var roleTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Enter Role..."
        textField.keyboardType = UIKeyboardType.default
        textField.returnKeyType = UIReturnKeyType.done
        textField.autocorrectionType = UITextAutocorrectionType.no
        textField.font = UIFont.systemFont(ofSize: 13)
        textField.borderStyle = UITextField.BorderStyle.roundedRect
        textField.clearButtonMode = UITextField.ViewMode.whileEditing;
        textField.contentVerticalAlignment = UIControl.ContentVerticalAlignment.center
        return textField
    }()

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

        title = "Project info editing"

        view.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.bottom.equalToSuperview()
        }

        // Project name
        contentView.addSubview(projectNameLabel)
        projectNameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(Constants.topInset)
            make.leading.equalToSuperview().inset(Constants.leadingInset)
        }

        contentView.addSubview(projectNameTextField)
        projectNameTextField.snp.makeConstraints { make in
            make.top.equalTo(projectNameLabel.snp.bottom).offset(Constants.labelToTextOffset)
            make.leading.equalToSuperview().inset(Constants.leadingInset)
            make.trailing.equalToSuperview().inset(Constants.trailingInset)
        }

        // Duration Experience of experience label + stepper + tableView
        contentView.addSubview(teamSizeLabel)
        teamSizeLabel.snp.makeConstraints { make in
            make.top.equalTo(projectNameTextField.snp.bottom).offset(Constants.moduleOffset)
            make.leading.equalToSuperview().inset(Constants.leadingInset)
        }

        contentView.addSubview(teamSizeStepper)
        teamSizeStepper.snp.makeConstraints { make in
            make.top.equalTo(teamSizeLabel.snp.bottom).offset(Constants.labelToTextOffset)
            make.leading.equalToSuperview().inset(Constants.leadingInset)
            //make.trailing.equalToSuperview().inset(Constants.trailingInset)
        }

        contentView.addSubview(teamSizeValueLabel)
        teamSizeValueLabel.snp.makeConstraints { make in
            make.centerY.equalTo(teamSizeStepper.snp.centerY)
            make.leading.equalTo(teamSizeStepper.snp.trailing).offset(Constants.stepperToLabelValueOffset)
        }
        
        
        // Project summary
        contentView.addSubview(projectSummaryLabel)
        projectSummaryLabel.snp.makeConstraints { make in
            make.top.equalTo(teamSizeValueLabel.snp.bottom).offset(Constants.moduleOffset)
            make.leading.equalToSuperview().inset(Constants.leadingInset)
        }

        contentView.addSubview(projectSummaryTextField)
        projectSummaryTextField.snp.makeConstraints { make in
            make.top.equalTo(projectSummaryLabel.snp.bottom).offset(Constants.labelToTextOffset)
            make.leading.equalToSuperview().inset(Constants.leadingInset)
            make.trailing.equalToSuperview().inset(Constants.trailingInset)
        }

        // Technology Used
        contentView.addSubview(technologyUsedLabel)
        technologyUsedLabel.snp.makeConstraints { make in
            make.top.equalTo(projectSummaryTextField.snp.bottom).offset(Constants.moduleOffset)
            make.leading.equalToSuperview().inset(Constants.leadingInset)
        }

        contentView.addSubview(technologyUsedTextField)
        technologyUsedTextField.snp.makeConstraints { make in
            make.top.equalTo(technologyUsedLabel.snp.bottom).offset(Constants.labelToTextOffset)
            make.leading.equalToSuperview().inset(Constants.leadingInset)
            make.trailing.equalToSuperview().inset(Constants.trailingInset)
        }

        // Project Role
        contentView.addSubview(roleLabel)
        roleLabel.snp.makeConstraints { make in
            make.top.equalTo(technologyUsedTextField.snp.bottom).offset(Constants.moduleOffset)
            make.leading.equalToSuperview().inset(Constants.leadingInset)
        }

        contentView.addSubview(roleTextField)
        roleTextField.snp.makeConstraints { make in
            make.top.equalTo(roleLabel.snp.bottom).offset(Constants.labelToTextOffset)
            make.leading.equalToSuperview().inset(Constants.leadingInset)
            make.trailing.equalToSuperview().inset(Constants.trailingInset)
        }
    }

    private func setupBindings() {
        let viewModel = dependencies.viewModelFactory.createViewModel(
            ProjectDetailViewModelFactory.Input(
                viewWillAppear: rx.viewWillAppear.asSignal(),
                saveResume: barButtonItem.rx.tap.asSignal(),
                projectNameText: projectNameTextField.rx.text.compactMap { $0 }.asDriver(onErrorJustReturn: "").skip(1),
                teamSize: teamSizeStepper.rx.value.map { Int($0) }.asDriver(onErrorJustReturn: 0),
                projectSummary: projectSummaryTextField.rx.text.compactMap { $0 }.asDriver(onErrorJustReturn: "").skip(1),
                technologyUsed: technologyUsedTextField.rx.text.compactMap { $0 }.asDriver(onErrorJustReturn: "").skip(1),
                role: roleTextField.rx.text.compactMap { $0 }.asDriver(onErrorJustReturn: "").skip(1)
            )
        )

        viewModel.allFieldValid
            .drive(onNext: { [weak self] isValid in
                guard let self = self else { return }

                self.barButtonItem.isEnabled = isValid
            })
            .disposed(by: disposeBag)

        viewModel.projectNameText.asObservable()
                .subscribe(onNext: { [weak self] projectName in
                    guard let self = self else { return }

                    self.projectNameTextField.text = projectName
                })
                .disposed(by: disposeBag)

        // Stepper init
        viewModel.teamSize
            .take(1)
            .drive(onNext: { [weak self] teamSize in
                guard let self = self else { return }

                self.teamSizeStepper.value = Double(teamSize)
            })
            .disposed(by: disposeBag)

        viewModel.teamSize
            .drive(onNext: { [weak self] teamSize in
                guard let self = self else { return }

                self.teamSizeValueLabel.text = "\(teamSize)"
            })
            .disposed(by: disposeBag)

        viewModel.projectSummary
            .drive(onNext: { [weak self] projectSummary in
                guard let self = self else { return }

                self.projectSummaryTextField.text = projectSummary
            })
            .disposed(by: disposeBag)

        viewModel.technologyUsed
            .drive(onNext: { [weak self] technologyUsed in
                guard let self = self else { return }

                self.technologyUsedTextField.text = technologyUsed
            })
            .disposed(by: disposeBag)

        viewModel.role
            .drive(onNext: { [weak self] role in
                guard let self = self else { return }

                self.roleTextField.text = role
            })
            .disposed(by: disposeBag)
    }
}

fileprivate enum Constants {
    static let topInset: CGFloat = 16
    static let leadingInset: CGFloat = 8
    static let trailingInset: CGFloat = 8
    static let labelToTextOffset: CGFloat = 6
    
    static let moduleOffset: CGFloat = 16

    static let stepperToLabelValueOffset: CGFloat = 16
}
