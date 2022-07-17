//
//  WorkSummaryCell.swift
//  ResumeCreator
//
//  Created by Oleg Pustoshkin on 18.04.2022.
//

import Foundation
import UIKit

final class WorkSummaryCell: UITableViewCell, ReusableIdentifierProtocol {

    static let reusableIdentifier = "WorkSummaryCell.id"

    private lazy var companyName: UILabel = {
        let label = UILabel()
        label.text = "Resume name"
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    
    private lazy var experienceDuration: UILabel = {
        let label = UILabel()
        label.text = "Experience:"
        label.font = .systemFont(ofSize: 16)
        return label
    }()

    func configure(model: WorkInfoModel) {
        companyName.text = "Company Name: \(model.companyName)"
        experienceDuration.text = "Experience: \(model.duration) years"
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none

        // Resume name
        contentView.addSubview(companyName)
        companyName.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(Constants.topInset)
            make.leading.equalToSuperview().inset(Constants.leadingInset)
        }
        
        contentView.addSubview(experienceDuration)
        experienceDuration.snp.makeConstraints { make in
            make.top.equalTo(companyName.snp.bottom).offset(Constants.labelToTextOffset)
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
