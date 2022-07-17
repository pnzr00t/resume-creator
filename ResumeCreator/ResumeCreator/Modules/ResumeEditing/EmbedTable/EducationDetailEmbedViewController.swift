//
//  EducationDetailEmbedViewController.swift
//  ResumeCreator
//
//  Created by Oleg Pustoshkin on 18.07.2022.
//

import Foundation
import UIKit

final class EducationDetailEmbedViewController: ReactiveTableViewViewController<EducationDetailModel, EducationDetailCell> {
    override func getCellForRowAtIndexPath(_ indexPath: IndexPath) -> UITableViewCell {
        if let reusableCell = tableView.dequeueReusableCell(withIdentifier: EducationDetailCell.reusableIdentifier, for: indexPath) as? EducationDetailCell {
            reusableCell.configure(model: super.dataList[indexPath.row])
            return reusableCell
        } else {
            let reusableCell = UITableViewCell()
            reusableCell.textLabel?.text = "\(super.dataList[indexPath.row].educationInstituteName)"
            return reusableCell
        }
    }
}
