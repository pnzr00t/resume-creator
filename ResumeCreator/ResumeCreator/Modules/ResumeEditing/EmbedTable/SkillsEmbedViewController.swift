//
//  SkillsEmbedViewController.swift
//  ResumeCreator
//
//  Created by Oleg Pustoshkin on 18.07.2022.
//

import Foundation
import UIKit

final class SkillsEmbedViewController: ReactiveTableViewViewController<String, SkillCell> {
    override func getCellForRowAtIndexPath(_ indexPath: IndexPath) -> UITableViewCell {
        let reusableCell = tableView.dequeueReusableCell(withIdentifier: SkillCell.reusableIdentifier, for: indexPath)
        reusableCell.textLabel?.text = "\(super.dataList[indexPath.row])"
        return reusableCell
    }
}
