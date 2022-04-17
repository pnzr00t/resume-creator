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
    var companyName: String
    var duration: Int

    static func createNewEmptyWorkInfo() -> WorkInfoModel {
        WorkInfoModel(companyName: "", duration: 0)
    }
}

struct EducationDetailModel {
    var educationInstituteName: String
    var classEducation: Int
    var passingYear: Date
    var percentage: Int

    static func createNewEmptyEducationDetail() -> EducationDetailModel {
        EducationDetailModel(educationInstituteName: "", classEducation: 0, passingYear: .now, percentage: 0)
    }
}

struct ProjectDetailModel {
    let projectName: String
    let teamSize: Int
    let projectSummary: String
    let technologyUsed: String
    let role: String

    static func createNewEmptyProjectDetail() -> ProjectDetailModel {
        ProjectDetailModel(projectName: "", teamSize: 0, projectSummary: "", technologyUsed: "", role: "")
    }
}
