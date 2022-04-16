//
//  ResumeEditingViewController.swift
//  ResumeCreator
//
//  Created by Oleg Pustoshkin on 14.04.2022.
//

import Foundation
import UIKit

struct ResumeEditingViewModelFactory {
    struct Dependencies {
        let editingResume: ResumeModel
        let resumeService: ResumeServiceProtocol
    }
    
    let dependencies: Dependencies
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
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
        scrollView.backgroundColor = .red
        return scrollView
    }()
    private lazy var contentView: UIView = {
        let contentView = UIView()
        contentView.backgroundColor = .blue
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
    private lazy var selfSizedTableView: SelfSizedTableView = {
        let selfSizedTableView = SelfSizedTableView()
        return selfSizedTableView
    }()

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
        
        contentView.addSubview(residenceAddressLabel)
        residenceAddressLabel.snp.makeConstraints { make in
            make.top.equalTo(avatarImage.snp.bottom).offset(Constants.moduleOffset)
            make.leading.equalToSuperview().inset(Constants.leadingInset)
        }
        
        contentView.addSubview(residenceAddressTextField)
        residenceAddressTextField.snp.makeConstraints { make in
            make.top.equalTo(residenceAddressLabel.snp.bottom).offset(Constants.labelToTextOffset)
            make.leading.equalToSuperview().inset(Constants.leadingInset)
            make.trailing.equalToSuperview().inset(Constants.trailingInset)
            
        }
        
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
        
        contentView.addSubview(selfSizedTableView)
        selfSizedTableView.snp.makeConstraints { make in
            make.top.equalTo(workSummaryLabel.snp.bottom).offset(Constants.labelToTextOffset)
            make.leading.equalToSuperview().inset(Constants.leadingInset)
            make.trailing.equalToSuperview().inset(Constants.trailingInset)
        }
        
        // Skills - label + add button + tableview
        contentView.addSubview(skillsLabel)
        skillsLabel.snp.makeConstraints { make in
            make.top.equalTo(selfSizedTableView.snp.bottom).offset(Constants.moduleOffset)
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
}
