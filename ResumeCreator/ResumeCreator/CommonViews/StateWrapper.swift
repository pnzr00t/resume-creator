//
//  StateWrapper.swift
//  ResumeCreator
//
//  Created by Oleg Pustoshkin on 16.04.2022.
//

import Foundation

class StateWrapper <Element> {
    var state: Element
    init(state: Element) {
        self.state = state
    }
}
