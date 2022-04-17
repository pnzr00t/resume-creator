//
//  EducationDetailViewController.swift
//  ResumeCreator
//
//  Created by Oleg Pustoshkin on 13.04.2022.
//

import RxCocoa
import RxSwift
import Foundation
import UIKit

struct EducationDetailModelFactory {
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
    }

    struct ViewModel {
        let allFieldValid: Driver<Bool>
        let educationInstituteNameText: Driver<String>
        let dateString: Driver<String>
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

        let educationInstituteNameValid = educationInstituteNameText.map({ $0.count > 0 }).asSignal(onErrorJustReturn: true)
        let allFieldValid = Signal.merge(educationInstituteNameValid)
            .startWith(false)

        return ViewModel(
            allFieldValid: allFieldValid.asDriver(onErrorJustReturn: true),
            educationInstituteNameText: educationInstituteNameText,
            dateString: dateString.asDriver(onErrorJustReturn: "")
        )
    }
}

class EducationDetailViewController: UIViewController {
    struct Dependencies {
        let viewModelFactory: EducationDetailModelFactory
    }
    
    private let dependencies: Dependencies
    weak var coordinator: EducationDetailCoordinator?

    private lazy var barButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: nil, action: nil)

    private let disposeBag = DisposeBag()

    private lazy var contentView: UIView = {
        let contentView = UIView()
        //contentView.backgroundColor = .blue
        return contentView
    }()

    private lazy var educationInstituteNameLabel: UILabel = {
        let label = UILabel()
        label.text = "Education Institute Name"
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    private lazy var educationInstituteNameTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Enter Education Institute Name..."
        textField.keyboardType = UIKeyboardType.default
        textField.returnKeyType = UIReturnKeyType.done
        textField.autocorrectionType = UITextAutocorrectionType.no
        textField.font = UIFont.systemFont(ofSize: 13)
        textField.borderStyle = UITextField.BorderStyle.roundedRect
        textField.clearButtonMode = UITextField.ViewMode.whileEditing;
        textField.contentVerticalAlignment = UIControl.ContentVerticalAlignment.center
        return textField
    }()

    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()

        datePicker.preferredDatePickerStyle = .wheels
        datePicker.datePickerMode = .date
        datePicker.maximumDate = Date()

        return datePicker
    }()
    private lazy var datePickerLabel: UILabel = {
        let label = UILabel()
        label.text = "Graduation Date"
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    private var doneBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: nil)
    private lazy var datePickerTextField: UITextField = {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()

        let doneBarButton = doneBarButton
        toolbar.setItems([doneBarButton], animated: true)


        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Enter Graduation Date..."
        textField.keyboardType = UIKeyboardType.default
        textField.returnKeyType = UIReturnKeyType.done
        textField.autocorrectionType = UITextAutocorrectionType.no
        textField.font = UIFont.systemFont(ofSize: 13)
        textField.borderStyle = UITextField.BorderStyle.roundedRect
        textField.clearButtonMode = UITextField.ViewMode.whileEditing;
        textField.contentVerticalAlignment = UIControl.ContentVerticalAlignment.center
        textField.allowsEditingTextAttributes = false
        
        textField.inputView = datePicker
        textField.inputAccessoryView = toolbar

        return textField
    }()
    private let datePickerPublisher = PublishRelay<Date>()

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

        title = "Education detail editing"
        
        view.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.bottom.equalToSuperview()
        }

        // Education institute name
        contentView.addSubview(educationInstituteNameLabel)
        educationInstituteNameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(Constants.topInset)
            make.leading.equalToSuperview().inset(Constants.leadingInset)
        }

        contentView.addSubview(educationInstituteNameTextField)
        educationInstituteNameTextField.snp.makeConstraints { make in
            make.top.equalTo(educationInstituteNameLabel.snp.bottom).offset(Constants.labelToTextOffset)
            make.leading.equalToSuperview().inset(Constants.leadingInset)
            make.trailing.equalToSuperview().inset(Constants.trailingInset)
        }


        // Date picker institute name
        contentView.addSubview(datePickerLabel)
        datePickerLabel.snp.makeConstraints { make in
            make.top.equalTo(educationInstituteNameTextField.snp.bottom).offset(Constants.moduleOffset)
            make.leading.equalToSuperview().inset(Constants.leadingInset)
        }

        contentView.addSubview(datePickerTextField)
        datePickerTextField.snp.makeConstraints { make in
            make.top.equalTo(datePickerLabel.snp.bottom).offset(Constants.labelToTextOffset)
            make.leading.equalToSuperview().inset(Constants.leadingInset)
            make.trailing.equalToSuperview().inset(Constants.trailingInset)
        }
    }

    private func setupBindings() {
        let viewModel = dependencies.viewModelFactory.createViewModel(
            EducationDetailModelFactory.Input(
                viewWillAppear: rx.viewWillAppear.asSignal(),
                saveResume: barButtonItem.rx.tap.asSignal(),
                educationInstituteNameText: educationInstituteNameTextField.rx.text.compactMap { $0 }.asDriver(onErrorJustReturn: "").skip(1),
                datePicker: datePickerPublisher.asSignal()
            )
        )

        viewModel.allFieldValid
            .drive(onNext: { [weak self] isValid in
                guard let self = self else { return }

                self.barButtonItem.isEnabled = isValid
            })
            .disposed(by: disposeBag)

        viewModel.educationInstituteNameText.asObservable()
                .subscribe(onNext: { [weak self] educationInstituteName in
                    guard let self = self else { return }

                    self.educationInstituteNameTextField.text = educationInstituteName
                })
                .disposed(by: disposeBag)


        // Date picker
        doneBarButton.rx.tap
            .subscribe { [weak self] _ in
                guard let self = self else { return }
                self.view.endEditing(true)
                self.datePickerPublisher.accept(self.datePicker.date)
            }
            .disposed(by: disposeBag)

        viewModel.dateString
            .drive(onNext: { [weak self] dateString in
                guard let self = self else { return }

                self.datePickerTextField.text = dateString
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
