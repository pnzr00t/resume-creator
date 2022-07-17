//
//  ProjectDetailEmbedViewController.swift
//  ResumeCreator
//
//  Created by Oleg Pustoshkin on 18.07.2022.
//

import Foundation
import UIKit

final class ProjectDetailEmbedViewController: ReactiveTableViewViewController<ProjectDetailModel, ProjectDetailCell> {
    override func getCellForRowAtIndexPath(_ indexPath: IndexPath) -> UITableViewCell {
        if let reusableCell = tableView.dequeueReusableCell(withIdentifier: ProjectDetailCell.reusableIdentifier, for: indexPath) as? ProjectDetailCell {
            reusableCell.configure(model: super.dataList[indexPath.row])
            return reusableCell
        } else {
            let reusableCell = UITableViewCell()
            reusableCell.textLabel?.text = "\(super.dataList[indexPath.row].projectName)"
            return reusableCell
        }
    }
}
