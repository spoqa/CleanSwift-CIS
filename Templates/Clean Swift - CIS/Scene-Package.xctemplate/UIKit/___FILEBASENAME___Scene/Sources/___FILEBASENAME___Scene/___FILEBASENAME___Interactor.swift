//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright (c) ___YEAR___ Spoqa. All rights reserved.
//

import Foundation

// MARK: - UseCase

enum ___VARIABLE_sceneName___UseCase {
    
}

// MARK: - Interactor

protocol ___VARIABLE_sceneName___Interactable {
    func execute(_ useCase: ___VARIABLE_sceneName___UseCase) async
}

final class ___VARIABLE_sceneName___Interactor: ___VARIABLE_sceneName___Interactable {
    
    private let store: ___VARIABLE_sceneName___Mutatable & Has___VARIABLE_sceneName___DomainState
    private let worker: ___VARIABLE_sceneName___Workable
    
    init(
        store: ___VARIABLE_sceneName___Mutatable & Has___VARIABLE_sceneName___DomainState,
        worker: ___VARIABLE_sceneName___Workable
    ) {
        self.store = store
        self.worker = worker
    }
}

// MARK: - Implement

extension ___VARIABLE_sceneName___Interactor {
    
    func execute(_ useCase: ___VARIABLE_sceneName___UseCase) async {
        switch useCase {
            
        }
    }
}
