//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright (c) ___YEAR___ Spoqa. All rights reserved.
//

import Foundation

// MARK: - Mutation

enum ___VARIABLE_productName___Mutation {
    
}

// MARK: - State

@MainActor public struct ___VARIABLE_productName___State {
    
    var domainState = DomainState()
    
    struct DomainState {
        
    }
    
    public init() {}
}

// MARK: - Store

protocol ___VARIABLE_productName___Mutatable: AnyObject {
    @MainActor func execute(_ mutation: ___VARIABLE_productName___Mutation)
}

protocol Has___VARIABLE_productName___DomainState: AnyObject {
    @MainActor var domainState: ___VARIABLE_productName___State.DomainState { get }
}

@MainActor final class ___VARIABLE_productName___Store: ___VARIABLE_productName___Mutatable, Has___VARIABLE_productName___DomainState, ObservableObject {
    
    let worker: ___VARIABLE_productName___Workable
    @Published private(set) var state: ___VARIABLE_productName___State
    var domainState: ___VARIABLE_productName___State.DomainState { self.state.domainState }
    
    init(
        worker: ___VARIABLE_productName___Workable,
        state: ___VARIABLE_productName___State
    ) {
        self.worker = worker
        self.state = state
    }
    
    func execute(_ mutation: ___VARIABLE_productName___Mutation) {
        self.state = self.execute(state: self.state, mutation: mutation)
    }
}

// MARK: - Implement

extension ___VARIABLE_productName___Store {
    
    private func execute(state: ___VARIABLE_productName___State, mutation: ___VARIABLE_productName___Mutation) -> ___VARIABLE_productName___State {
        var state = state
        
        switch mutation {
            
        }
        
        return state
    }
}
