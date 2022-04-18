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
    enum ClassEducation: Int, CaseIterable {
        case graduation
        case classI
        case classII
        case classIII
        case classIV
        case classV
        case classVI
        case classVII
        case classVIII
        case classIX
        case classX
        case classXI
        case classXII
        case classUnknown

        init(id : Int) {
            switch id {
            case 0: self = .graduation
            case 1: self = .classI
            case 2: self = .classII
            case 3: self = .classIII
            case 4: self = .classIV
            case 5: self = .classV
            case 6: self = .classVI
            case 7: self = .classVII
            case 8: self = .classVIII
            case 9: self = .classIX
            case 10: self = .classX
            case 11: self = .classXI
            case 12: self = .classXII
            case 13: self = .classUnknown
            default: self = .classUnknown
            }
        }

        func getString() -> String {
            switch self {
            case .graduation:
                return "Graduation"
            case .classI:
                return "Class I"
            case .classII:
                return "Class II"
            case .classIII:
                return "Class III"
            case .classIV:
                return "Class IV"
            case .classV:
                return "Class V"
            case .classVI:
                return "Class VI"
            case .classVII:
                return "Class VII"
            case .classVIII:
                return "Class VIII"
            case .classIX:
                return "Class IX"
            case .classX:
                return "Class X"
            case .classXI:
                return "Class XI"
            case .classXII:
                return "Class XII"
            case .classUnknown:
                return "Unknown"
            }
        }
    }

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
