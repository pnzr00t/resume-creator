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

    var id: Identifier
    var resumeName: String
    var picture: UIImage?
    var mobileNumberString: String
    var emailAddress: String
    var residenceAddress: String
    var careerObjective: String
    var totalYearsOfExperience: Int
    var workSummaryList: [WorkInfoModel]
    var skillsList: [String]
    var educationDetailList: [EducationDetailModel]
    var projectDetailList: [ProjectDetailModel]

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
