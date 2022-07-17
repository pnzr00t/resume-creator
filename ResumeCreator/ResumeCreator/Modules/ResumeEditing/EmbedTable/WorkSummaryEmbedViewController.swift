//
//  WorkSummaryEmbedViewController.swift
//  ResumeCreator
//
//  Created by Oleg Pustoshkin on 17.07.2022.
//

import Foundation
import UIKit

final class WorkSummaryEmbedViewController: ReactiveTableViewViewController<WorkInfoModel, WorkSummaryCell> {
    override func getCellForRowAtIndexPath(_ indexPath: IndexPath) -> UITableViewCell {
        if let reusableCell = super.tableView.dequeueReusableCell(withIdentifier: WorkSummaryCell.reusableIdentifier, for: indexPath) as? WorkSummaryCell {
            reusableCell.configure(model: super.dataList[indexPath.row])
            return reusableCell
        } else {
            let reusableCell = UITableViewCell()
            reusableCell.textLabel?.text = "\(super.dataList[indexPath.row].companyName)"
            return reusableCell
        }
    }
}
