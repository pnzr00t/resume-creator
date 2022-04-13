//
//  ResumeMockManager.swift
//  ResumeCreator
//
//  Created by Oleg Pustoshkin on 12.04.2022.
//

import Foundation
import UIKit


class ResumeMockManager: ResumeManagerProtocol {
    func getResumeCount() -> Int {
        1
    }
    
    func getResume(index: Int) -> ResumeModel? {
        return ResumeModel(
            resumeName: "test",
            picture: UIImage(systemName: "search"),
            mobileNumberString: "+79631092767",
            emailAddress: "pnz.r00t@gmail.com",
            residenteAddress: "Russia Penza",
            careerObjective: "iOS developer",
            totalYearsOfExperience: 4,
            workSummaryList: [WorkInfoModel(companyName: "Amma.family", duration: 2)],
            skillsList: ["iOS developer", "Analytic manager"],
            educationDetailList: [EducationDetailModel(classEducation: 4, passingYear: Date(), percentage: 99)],
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
    }
    
    func addResume(_ resume: ResumeModel) {
    }
    
    func replaceResume(at index: Int, resume: ResumeModel) {
    }
}
