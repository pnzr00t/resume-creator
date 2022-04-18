//
//  ResumeMockManager.swift
//  ResumeCreator
//
//  Created by Oleg Pustoshkin on 12.04.2022.
//

import Foundation
import UIKit


class ResumeMockService: ResumeServiceProtocol {
    var outResumeList = [ResumeModel]()
    
    // FIXME: Delete after module creating
    init() {
        outResumeList.append(
            ResumeModel(
                id: .existing(UUID()),
                resumeName: "test",
                picture: UIImage(systemName: "search"),
                mobileNumberString: "+79631092767",
                emailAddress: "pnz.r00t@gmail.com",
                residenceAddress: "Russia Penza",
                careerObjective: "iOS developer",
                totalYearsOfExperience: 4,
                workSummaryList: [WorkInfoModel(companyName: "Amma.family", duration: 2)],
                skillsList: ["iOS developer", "Analytic manager"],
                educationDetailList: [EducationDetailModel(educationInstituteName: "Penza state university", classEducation: 4, passingYear: Date(), percentage: 99)],
                projectDetailList: [
                    ProjectDetailModel(
                        projectName: "Pregnancy Tracker",
                        teamSize: 15,
                        projectSummary: "1st in Pregnancy category",
                        technologyUsed: "kean/Align, rxSwift",
                        role: "iOS develoer"
                    )
                ]
            )
        )

        outResumeList.append(
            ResumeModel(
                id: .existing(UUID()),
                resumeName: "test2",
                picture: UIImage(systemName: "search"),
                mobileNumberString: "+79631092767",
                emailAddress: "pnz.r00t@gmail.com",
                residenceAddress: "Russia Penza",
                careerObjective: "iOS developer",
                totalYearsOfExperience: 4,
                workSummaryList: [WorkInfoModel(companyName: "Amma.family", duration: 2)],
                skillsList: ["iOS developer", "Analytic manager"],
                educationDetailList: [EducationDetailModel(educationInstituteName: "Moscow state university", classEducation: 4, passingYear: Date(), percentage: 99)],
                projectDetailList: [
                    ProjectDetailModel(
                        projectName: "Pregnancy Tracker",
                        teamSize: 15,
                        projectSummary: "1st in Pregnancy category",
                        technologyUsed: "kean/Align, rxSwift",
                        role: "iOS develoer"
                    )
                ]
            )
        )

        outResumeList.append(
            ResumeModel(
                id: .existing(UUID()),
                resumeName: "test3",
                picture: UIImage(systemName: "search"),
                mobileNumberString: "+79631092767",
                emailAddress: "pnz.r00t@gmail.com",
                residenceAddress: "Russia Penza",
                careerObjective: "iOS developer",
                totalYearsOfExperience: 4,
                workSummaryList: [WorkInfoModel(companyName: "Amma.family", duration: 2)],
                skillsList: ["iOS developer", "Analytic manager"],
                educationDetailList: [EducationDetailModel(educationInstituteName: "Chicago university", classEducation: 4, passingYear: Date(), percentage: 99)],
                projectDetailList: [
                    ProjectDetailModel(
                        projectName: "Pregnancy Tracker",
                        teamSize: 15,
                        projectSummary: "1st in Pregnancy category",
                        technologyUsed: "kean/Align, rxSwift",
                        role: "iOS develoer"
                    )
                ]
            )
        )

        outResumeList.append(
            ResumeModel(
                id: .existing(UUID()),
                resumeName: "test4",
                picture: UIImage(systemName: "search"),
                mobileNumberString: "+79631092767",
                emailAddress: "pnz.r00t@gmail.com",
                residenceAddress: "Russia Penza",
                careerObjective: "iOS developer",
                totalYearsOfExperience: 4,
                workSummaryList: [WorkInfoModel(companyName: "Amma.family", duration: 2)],
                skillsList: ["iOS developer", "Analytic manager"],
                educationDetailList: [EducationDetailModel(educationInstituteName: "MIT", classEducation: 4, passingYear: Date(), percentage: 99)],
                projectDetailList: [
                    ProjectDetailModel(
                        projectName: "Pregnancy Tracker",
                        teamSize: 15,
                        projectSummary: "1st in Pregnancy category",
                        technologyUsed: "kean/Align, rxSwift",
                        role: "iOS develoer"
                    )
                ]
            )
        )
    }

    func getResumeList() -> [ResumeModel] {
        return outResumeList
    }

    func getResumeCount() -> Int {
        return outResumeList.count
    }

    func getResume(index: Int) -> ResumeModel? {
        return outResumeList[index]
    }

    func addResume(_ resume: ResumeModel) -> ResumeModel? {
        var resumeCopy = resume
        resumeCopy.id = .existing(UUID())
        outResumeList.append(resumeCopy)
        return resumeCopy
    }

    func replaceResume(at index: Int, resume: ResumeModel) {
        outResumeList[index] = resume
    }

    func removeObject(_ resume: ResumeModel) {
        guard case .existing = resume.id else { return }

        outResumeList.removeAll { resumeModel in
            resume.id == resumeModel.id ? true : false
        }
    }

    func editResume(_ resume: ResumeModel) -> ResumeModel? {
        guard case let .existing(resumeId) = resume.id else { return addResume(resume) }
        
        for (index, resumeFromList) in outResumeList.enumerated() {
            if case let .existing(uuid) = resumeFromList.id, resumeId == uuid {
                outResumeList[index] = resume
                return resume
            }
        }

        return nil
    }
}
