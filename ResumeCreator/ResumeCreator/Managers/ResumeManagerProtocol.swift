//
//  ResumeManagerProtocol.swift
//  ResumeCreator
//
//  Created by Oleg Pustoshkin on 12.04.2022.
//

import Foundation

protocol ResumeManagerProtocol {
    func getResumeCount() -> Int
    func getResume(index: Int) -> ResumeModel?
    func addResume(_ resume: ResumeModel)
    func replaceResume(at index: Int, resume: ResumeModel)
}
