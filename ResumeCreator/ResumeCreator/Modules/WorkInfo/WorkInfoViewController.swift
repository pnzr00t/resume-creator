//
//  WorkInfoViewController.swift
//  ResumeCreator
//
//  Created by Oleg Pustoshkin on 13.04.2022.
//

import RxCocoa
import RxSwift
import Foundation
import UIKit


class WorkInfoViewController: UIViewController {
    struct Dependencies {
        let viewModelFactory: WorkInfoViewModelFactory
    }
    
    private let dependencies: Dependencies
    weak var coordinator: WorkInfoCoordinator?

    private lazy var barButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: nil, action: nil)

    private let disposeBag = DisposeBag()

    private lazy var contentView: UIView = {
        let contentView = UIView()

        return contentView
    }()

    /// Company Name
    private lazy var companyNameLabel: UILabel = {
        let label = UILabel()
        label.text = "Company Name"
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    lazy var companyNameTextField: UITextField = {
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

    /// Experience duration
    private lazy var durationExperienceLabel: UILabel = {
        let label = UILabel()
        label.text = "Total years of experience"
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    private lazy var durationExperienceStepper: UIStepper = {
        let stepper = UIStepper()
        stepper.minimumValue = 0
        stepper.maximumValue = 70
        stepper.stepValue = 1
        stepper.value = 0
        return stepper
    }()
    private lazy var durationExperienceValueLabel: UILabel = {
        let label = UILabel()
        label.text = "0"
        label.font = .systemFont(ofSize: 16)
        return label
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

        title = "Work info editing"

        view.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.bottom.equalToSuperview()
        }

        // Resume name
        contentView.addSubview(companyNameLabel)
        companyNameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(Constants.topInset)
            make.leading.equalToSuperview().inset(Constants.leadingInset)
        }

        contentView.addSubview(companyNameTextField)
        companyNameTextField.snp.makeConstraints { make in
            make.top.equalTo(companyNameLabel.snp.bottom).offset(Constants.labelToTextOffset)
            make.leading.equalToSuperview().inset(Constants.leadingInset)
            make.trailing.equalToSuperview().inset(Constants.trailingInset)
        }

        // Duration Experience of experience label + stepper + tableView
        contentView.addSubview(durationExperienceLabel)
        durationExperienceLabel.snp.makeConstraints { make in
            make.top.equalTo(companyNameTextField.snp.bottom).offset(Constants.moduleOffset)
            make.leading.equalToSuperview().inset(Constants.leadingInset)
        }

        contentView.addSubview(durationExperienceStepper)
        durationExperienceStepper.snp.makeConstraints { make in
            make.top.equalTo(durationExperienceLabel.snp.bottom).offset(Constants.labelToTextOffset)
            make.leading.equalToSuperview().inset(Constants.leadingInset)
        }

        contentView.addSubview(durationExperienceValueLabel)
        durationExperienceValueLabel.snp.makeConstraints { make in
            make.centerY.equalTo(durationExperienceStepper.snp.centerY)
            make.leading.equalTo(durationExperienceStepper.snp.trailing).offset(Constants.stepperToLabelValueOffset)
        }
    }

    private func setupBindings() {
        let viewModel = dependencies.viewModelFactory.createViewModel(
            WorkInfoViewModelFactory.Input(
                viewWillAppear: rx.viewWillAppear.asSignal(),
                saveResume: barButtonItem.rx.tap.asSignal(),
                companyNameText: companyNameTextField.rx.text.compactMap { $0 }.asDriver(onErrorJustReturn: "").skip(1),
                durationYearsOfExperience: durationExperienceStepper.rx.value.map { Int($0) }.asDriver(onErrorJustReturn: 0)
            )
        )

        viewModel.allFieldValid
            .drive(onNext: { [weak self] isValid in
                guard let self = self else { return }

                self.barButtonItem.isEnabled = isValid
            })
            .disposed(by: disposeBag)

        viewModel.companyNameText.asObservable()
                .subscribe(onNext: { [weak self] companyName in
                    guard let self = self else { return }

                    self.companyNameTextField.text = companyName
                })
                .disposed(by: disposeBag)

        // Stepper init
        viewModel.durationYearsOfExperience
            .take(1)
            .drive(onNext: { [weak self] durationYearsOfExperience in
                guard let self = self else { return }

                self.durationExperienceStepper.value = Double(durationYearsOfExperience)
            })
            .disposed(by: disposeBag)

        viewModel.durationYearsOfExperience
            .drive(onNext: { [weak self] durationYearsOfExperience in
                guard let self = self else { return }

                self.durationExperienceValueLabel.text = "\(durationYearsOfExperience)"
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
