//
//  ResumeRealmModel.swift
//  ResumeCreator
//
//  Created by Oleg Pustoshkin on 12.04.2022.
//

import RealmSwift

final class ResumeEntity: Object {
    @Persisted(primaryKey: true) var id: UUID = UUID()
    @Persisted var resumeName: String
    @Persisted var picture: Data?
    @Persisted var mobileNumberString: String
    @Persisted var emailAddress: String
    @Persisted var residenceAddress: String
    @Persisted var careerObjective: String
    @Persisted var totalYearsOfExperience: Int
    @Persisted var workSummaryList: List<WorkInfoEntity>
    @Persisted var skillsList: List<String>
    @Persisted var educationDetailList: List<EducationDetailEntity>
    @Persisted var projectDetailList: List<ProjectDetailEntity>

    var model: ResumeModel? {
        var resumePicture: UIImage?
        if let pictureData = picture {
            resumePicture = UIImage(data: pictureData)
        }

        var skillList = [String]()
        for skill in self.skillsList {
            skillList.append(skill)
        }

        var workSummaryList = [WorkInfoModel]()
        for workSummary in self.workSummaryList {
            workSummaryList.append(workSummary.model)
        }

        var educationDetailList = [EducationDetailModel]()
        for educationDetail in self.educationDetailList {
            educationDetailList.append(educationDetail.model)
        }
        
        var projectDetailList = [ProjectDetailModel]()
        for projectDetail in self.projectDetailList {
            projectDetailList.append(projectDetail.model)
        }

        return ResumeModel(
            id: .existing(id),
            resumeName: resumeName,
            picture: resumePicture,
            mobileNumberString: mobileNumberString,
            emailAddress: emailAddress,
            residenceAddress: residenceAddress,
            careerObjective: careerObjective,
            totalYearsOfExperience: totalYearsOfExperience,
            workSummaryList: workSummaryList,
            skillsList: skillList,
            educationDetailList: educationDetailList,
            projectDetailList: projectDetailList
        )
    }
    
    func update(from model: ResumeModel) {
        resumeName = model.resumeName
        picture = model.picture?.pngData()
        mobileNumberString = model.mobileNumberString
        emailAddress = model.emailAddress
        residenceAddress = model.residenceAddress
        careerObjective = model.careerObjective
        totalYearsOfExperience = model.totalYearsOfExperience

        workSummaryList.removeAll()
        workSummaryList.append(
            objectsIn: model.workSummaryList
                .map{ workInfoModel in
                    let workInfoEntity = WorkInfoEntity()

                    workInfoEntity.companyName = workInfoModel.companyName
                    workInfoEntity.duration = workInfoModel.duration

                    return workInfoEntity
                }
                                
        )

        skillsList.removeAll()
        skillsList.append(objectsIn: model.skillsList)

        educationDetailList.removeAll()
        educationDetailList.append(
            objectsIn: model.educationDetailList
                .map { educationDetailModel in
                    let educationDetailEntity = EducationDetailEntity()

                    educationDetailEntity.classEducation = educationDetailModel.classEducation
                    educationDetailEntity.passingYear = educationDetailModel.passingYear
                    educationDetailEntity.percentage = educationDetailModel.percentage

                    return educationDetailEntity
                }
        )

        projectDetailList.removeAll()
        projectDetailList.append(
            objectsIn: model.projectDetailList
                .map { projectDetailModel in
                    let projectDetailEntity = ProjectDetailEntity()

                    projectDetailEntity.projectName = projectDetailModel.projectName
                    projectDetailEntity.teamSize = projectDetailModel.teamSize
                    projectDetailEntity.projectSummary = projectDetailModel.projectSummary
                    projectDetailEntity.technologyUsed = projectDetailModel.technologyUsed
                    projectDetailEntity.role = projectDetailModel.role

                    return projectDetailEntity
                }
        )
    }
}

final class WorkInfoEntity: EmbeddedObject {
    @Persisted var companyName: String
    @Persisted var duration: Int

    var model: WorkInfoModel {
        return WorkInfoModel(companyName: companyName, duration: duration)
    }
}

final class EducationDetailEntity: EmbeddedObject {
    @Persisted var classEducation: Int
    @Persisted var passingYear: Date
    @Persisted var percentage: Int

    var model: EducationDetailModel {
        return EducationDetailModel(classEducation: classEducation, passingYear: passingYear, percentage: percentage)
    }
}

final class ProjectDetailEntity: EmbeddedObject {
    @Persisted var projectName: String
    @Persisted var teamSize: Int
    @Persisted var projectSummary: String
    @Persisted var technologyUsed: String
    @Persisted var role: String

    var model: ProjectDetailModel {
        return ProjectDetailModel(
            projectName: projectName,
            teamSize: teamSize,
            projectSummary: projectSummary,
            technologyUsed: technologyUsed,
            role: role
        )
    }
}
