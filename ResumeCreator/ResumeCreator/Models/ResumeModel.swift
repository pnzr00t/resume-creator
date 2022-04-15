//
//  ResumeModel.swift
//  ResumeCreator
//
//  Created by Oleg Pustoshkin on 12.04.2022.
//

import Foundation
import UIKit

struct ResumeModel {
    enum Identifier: Hashable {
        case new
        case existing(UUID)
    }

    let id: Identifier
    let resumeName: String
    let picture: UIImage?
    let mobileNumberString: String
    let emailAddress: String
    let residenceAddress: String
    let careerObjective: String
    let totalYearsOfExperience: Int
    let workSummaryList: [WorkInfoModel]
    let skillsList: [String]
    let educationDetailList: [EducationDetailModel]
    let projectDetailList: [ProjectDetailModel]

    static func createNewEmptyResume() -> ResumeModel {
        ResumeModel(
            id: .new,
            resumeName: "",
            picture: nil,
            mobileNumberString: "",
            emailAddress: "",
            residenceAddress: "",
            careerObjective: "",
            totalYearsOfExperience: 0,
            workSummaryList: [],
            skillsList: [],
            educationDetailList: [],
            projectDetailList: []
        )
    }
}

struct WorkInfoModel {
    let companyName: String
    let duration: Int
}

struct EducationDetailModel {
    let classEducation: Int
    let passingYear: Date
    let percentage: Int
}

struct ProjectDetailModel {
    let projectName: String
    let teamSize: Int
    let projectSummary: String
    let technologyUsed: String
    let role: String
}
