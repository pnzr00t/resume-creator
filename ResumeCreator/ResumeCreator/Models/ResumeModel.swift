//
//  ResumeModel.swift
//  ResumeCreator
//
//  Created by Oleg Pustoshkin on 12.04.2022.
//

import Foundation

struct ResumeModel {
    let resumeName: String
    let mobileNumberString: String
    let emailAddress: String
    let residenteAddress: String
    let careerObjective: String
    let totalYearsOfExperience: Int
    let workSummaryList: [WorkInfoModel]
    let skillsList: [String]
    let educationDetailList: [EducationDetailModel]
    let projectDetail: [ProjectDetailModel]
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
