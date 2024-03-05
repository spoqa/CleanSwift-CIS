//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright (c) ___YEAR___ Spoqa. All rights reserved.
//

import Foundation

// MARK: - UseCase

enum ___VARIABLE_productName___UseCase {
    
}

// MARK: - Interactor

protocol ___VARIABLE_productName___Interactable {
    func execute(_ useCase: ___VARIABLE_productName___UseCase) async
}

final class ___VARIABLE_productName___Interactor: ___VARIABLE_productName___Interactable {
    
    private let store: ___VARIABLE_productName___Mutatable & Has___VARIABLE_productName___DomainState
    private let worker: ___VARIABLE_productName___Workable
    
    init(
        store: ___VARIABLE_productName___Mutatable & Has___VARIABLE_productName___DomainState,
        worker: ___VARIABLE_productName___Workable
    ) {
        self.store = store
        self.worker = worker
    }
}

// MARK: - Implement

extension ___VARIABLE_productName___Interactor {
    
    func execute(_ useCase: ___VARIABLE_productName___UseCase) async {
        switch useCase {
            
        }
    }
}
