//
//  ProjectDetailCell.swift
//  ResumeCreator
//
//  Created by Oleg Pustoshkin on 18.04.2022.
//

import Foundation
import UIKit

final class ProjectDetailCell: UITableViewCell, ReusableIdentifierProtocol {

    static let reusableIdentifier = "ProjectDetailCell.id"

    private lazy var projectName: UILabel = {
        let label = UILabel()
        label.text = "Project Name"
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    
    private lazy var teamSize: UILabel = {
        let label = UILabel()
        label.text = "Team size"
        label.font = .systemFont(ofSize: 16)
        return label
    }()

    private lazy var projectRole: UILabel = {
        let label = UILabel()
        label.text = "Role"
        label.font = .systemFont(ofSize: 16)
        return label
    }()

    func configure(model: ProjectDetailModel) {
        projectName.text = "Project name: \(model.projectName)"
        teamSize.text = "Team size: \(model.teamSize)"
        projectRole.text = "Role: \(model.projectName)"
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none

        contentView.addSubview(projectName)
        projectName.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(Constants.topInset)
            make.leading.equalToSuperview().inset(Constants.leadingInset)
        }

        contentView.addSubview(teamSize)
        teamSize.snp.makeConstraints { make in
            make.top.equalTo(projectName.snp.bottom).offset(Constants.labelToTextOffset)
            make.leading.equalToSuperview().inset(Constants.leadingInset)
        }

        contentView.addSubview(projectRole)
        projectRole.snp.makeConstraints { make in
            make.top.equalTo(teamSize.snp.bottom).offset(Constants.labelToTextOffset)
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
