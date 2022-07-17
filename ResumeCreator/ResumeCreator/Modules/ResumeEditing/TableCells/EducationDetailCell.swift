//
//  EducationDetailCell.swift
//  ResumeCreator
//
//  Created by Oleg Pustoshkin on 18.04.2022.
//

import Foundation
import UIKit

final class EducationDetailCell: UITableViewCell, ReusableIdentifierProtocol {

    static let reusableIdentifier = "EducationDetailCell.id"

    private lazy var educationInstituteName: UILabel = {
        let label = UILabel()
        label.text = "Resume name"
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    
    private lazy var classEducation: UILabel = {
        let label = UILabel()
        label.text = "Resume name"
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    
    private lazy var passingYear: UILabel = {
        let label = UILabel()
        label.text = "Passing year"
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    
    private lazy var percentage: UILabel = {
        let label = UILabel()
        label.text = "percentage"
        label.font = .systemFont(ofSize: 16)
        return label
    }()

    func configure(model: EducationDetailModel) {
        let dateFormatter = DateFormatter()
        dateFormatter.setLocalizedDateFormatFromTemplate("yyyy")

        educationInstituteName.text = "Institute Name: \(model.educationInstituteName)"
        classEducation.text = "Education class: \(EducationDetailModel.ClassEducation(id: model.classEducation).getString())"
        passingYear.text = "Passing in: \(dateFormatter.string(from: model.passingYear)) year"
        percentage.text = "Passing: \(model.percentage)%"
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none

        contentView.addSubview(educationInstituteName)
        educationInstituteName.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(Constants.topInset)
            make.leading.equalToSuperview().inset(Constants.leadingInset)
        }
        
        contentView.addSubview(classEducation)
        classEducation.snp.makeConstraints { make in
            make.top.equalTo(educationInstituteName.snp.bottom).offset(Constants.labelToTextOffset)
            make.leading.equalToSuperview().inset(Constants.leadingInset)
        }
        
        contentView.addSubview(passingYear)
        passingYear.snp.makeConstraints { make in
            make.top.equalTo(classEducation.snp.bottom).offset(Constants.labelToTextOffset)
            make.leading.equalToSuperview().inset(Constants.leadingInset)
        }
        
        contentView.addSubview(percentage)
        percentage.snp.makeConstraints { make in
            make.top.equalTo(passingYear.snp.bottom).offset(Constants.labelToTextOffset)
            make.leading.equalToSuperview().inset(Constants.leadingInset)
            make.bottom.equalToSuperview().inset(Constants.bottomInsert)
        }
    }

    @available(*, unavailable) required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

fileprivate enum Constants {
    static let topInset: CGFloat = 16
    static let leadingInset: CGFloat = 8
    static let trailingInset: CGFloat = 8
    static let labelToTextOffset: CGFloat = 6
    static let bottomInsert: CGFloat = 16
}
