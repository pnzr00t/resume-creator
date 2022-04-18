//
//  ResumeManagerProtocol.swift
//  ResumeCreator
//
//  Created by Oleg Pustoshkin on 12.04.2022.
//

import Foundation

protocol ResumeServiceProtocol {
    func getResumeCount() -> Int
    func getResume(index: Int) -> ResumeModel?
    func addResume(_ resume: ResumeModel) -> ResumeModel?
    func replaceResume(at index: Int, resume: ResumeModel)

    func getResumeList() -> [ResumeModel]
    func removeObject(_ resume: ResumeModel)
    func editResume(_ resume: ResumeModel) -> ResumeModel?
}
