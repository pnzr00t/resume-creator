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



class EducationDetailViewController: UIViewController {
    struct Dependencies {
        let viewModelFactory: EducationDetailViewModelFactory
    }
    
    private let dependencies: Dependencies
    weak var coordinator: EducationDetailCoordinator?

    private lazy var barButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: nil, action: nil)

    private let disposeBag = DisposeBag()

    private lazy var contentView: UIView = {
        let contentView = UIView()

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

    /// Date picker + label + DatePicker ToolBar
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

    /// Class picker + label + classPicker ToolBar
    private lazy var classPicker: UIPickerView = {
        let classPicker = UIPickerView()

        return classPicker
    }()
    private lazy var classPickerLabel: UILabel = {
        let label = UILabel()
        label.text = "Class"
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    private var choiceClassDoneBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: nil)
    private lazy var classPickerTextField: UITextField = {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()

        toolbar.setItems([choiceClassDoneBarButton], animated: true)


        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Choice Class..."
        textField.keyboardType = UIKeyboardType.default
        textField.returnKeyType = UIReturnKeyType.done
        textField.autocorrectionType = UITextAutocorrectionType.no
        textField.font = UIFont.systemFont(ofSize: 13)
        textField.borderStyle = UITextField.BorderStyle.roundedRect
        textField.clearButtonMode = UITextField.ViewMode.whileEditing;
        textField.contentVerticalAlignment = UIControl.ContentVerticalAlignment.center
        textField.allowsEditingTextAttributes = false
        
        textField.inputView = classPicker
        textField.inputAccessoryView = toolbar

        return textField
    }()
    private let classPickerPublisher = PublishRelay<Int>()
    
    /// Percentage/CGPA + label + percentagePicker ToolBar
    private lazy var percentagePicker: UIPickerView = {
        let percentagePicker = UIPickerView()

        return percentagePicker
    }()
    private lazy var percentagePickerLabel: UILabel = {
        let label = UILabel()
        label.text = "Percentage/CGPA"
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    private var choicePercentageDoneBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: nil)
    private lazy var percentagePickerTextField: UITextField = {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()

        toolbar.setItems([choicePercentageDoneBarButton], animated: true)

        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Choice Percentage/CGPA..."
        textField.keyboardType = UIKeyboardType.default
        textField.returnKeyType = UIReturnKeyType.done
        textField.autocorrectionType = UITextAutocorrectionType.no
        textField.font = UIFont.systemFont(ofSize: 13)
        textField.borderStyle = UITextField.BorderStyle.roundedRect
        textField.clearButtonMode = UITextField.ViewMode.whileEditing;
        textField.contentVerticalAlignment = UIControl.ContentVerticalAlignment.center
        textField.allowsEditingTextAttributes = false
        
        textField.inputView = percentagePicker
        textField.inputAccessoryView = toolbar

        return textField
    }()
    private let percentagePickerPublisher = PublishRelay<Int>()

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

        title = "Education detail editing"

        self.classPicker.delegate = self
        self.classPicker.dataSource = self

        self.percentagePicker.delegate = self
        self.percentagePicker.dataSource = self

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

        // Class picker institute name
        contentView.addSubview(classPickerLabel)
        classPickerLabel.snp.makeConstraints { make in
            make.top.equalTo(datePickerTextField.snp.bottom).offset(Constants.moduleOffset)
            make.leading.equalToSuperview().inset(Constants.leadingInset)
        }

        contentView.addSubview(classPickerTextField)
        classPickerTextField.snp.makeConstraints { make in
            make.top.equalTo(classPickerLabel.snp.bottom).offset(Constants.labelToTextOffset)
            make.leading.equalToSuperview().inset(Constants.leadingInset)
            make.trailing.equalToSuperview().inset(Constants.trailingInset)
        }
        
        // Percentage/CGPA picker institute name
        contentView.addSubview(percentagePickerLabel)
        percentagePickerLabel.snp.makeConstraints { make in
            make.top.equalTo(classPickerTextField.snp.bottom).offset(Constants.moduleOffset)
            make.leading.equalToSuperview().inset(Constants.leadingInset)
        }

        contentView.addSubview(percentagePickerTextField)
        percentagePickerTextField.snp.makeConstraints { make in
            make.top.equalTo(percentagePickerLabel.snp.bottom).offset(Constants.labelToTextOffset)
            make.leading.equalToSuperview().inset(Constants.leadingInset)
            make.trailing.equalToSuperview().inset(Constants.trailingInset)
        }
    }

    private func setupBindings() {
        let viewModel = dependencies.viewModelFactory.createViewModel(
            EducationDetailViewModelFactory.Input(
                viewWillAppear: rx.viewWillAppear.asSignal(),
                saveResume: barButtonItem.rx.tap.asSignal(),
                educationInstituteNameText: educationInstituteNameTextField.rx.text.compactMap { $0 }.asDriver(onErrorJustReturn: "").skip(1),
                datePicker: datePickerPublisher.asSignal(),
                classPicker: classPickerPublisher.asSignal(),
                percentagePicker: percentagePickerPublisher.asSignal()
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

        // Class picker
        choiceClassDoneBarButton.rx.tap
            .subscribe { [weak self] _ in
                guard let self = self else { return }
                self.view.endEditing(true)

                let selectedRow = self.classPicker.selectedRow(inComponent: 0)
                self.classPickerPublisher.accept(selectedRow)
            }
            .disposed(by: disposeBag)

        viewModel.classString
            .drive(onNext: { [weak self] classString in
                guard let self = self else { return }

                self.classPickerTextField.text = classString
            })
            .disposed(by: disposeBag)

        // Percentage picker
        choicePercentageDoneBarButton.rx.tap
            .subscribe { [weak self] _ in
                guard let self = self else { return }
                self.view.endEditing(true)

                let selectedRow = self.percentagePicker.selectedRow(inComponent: 0)
                self.percentagePickerPublisher.accept(selectedRow)
            }
            .disposed(by: disposeBag)

        viewModel.percentageString
            .drive(onNext: { [weak self] percentageString in
                guard let self = self else { return }

                self.percentagePickerTextField.text = percentageString
            })
            .disposed(by: disposeBag)
    }
}

extension EducationDetailViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        if pickerView === classPicker {
            return 1
        }

        if pickerView === percentagePicker {
            return 1
        }
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView === classPicker {
            return EducationDetailModel.ClassEducation.allCases.count
        }

        if pickerView === percentagePicker {
            return Array(0...100).count
        }
        return 0
    }
    
}

extension EducationDetailViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView === classPicker {
            return EducationDetailModel.ClassEducation(id: row).getString()
        }

        if pickerView === percentagePicker {
            return "\(row)%"
        }
        return nil
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
