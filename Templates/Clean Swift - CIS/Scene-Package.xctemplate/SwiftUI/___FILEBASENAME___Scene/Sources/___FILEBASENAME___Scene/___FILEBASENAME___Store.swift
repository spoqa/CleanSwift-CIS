//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright (c) ___YEAR___ Spoqa. All rights reserved.
//

import Foundation

// MARK: - Mutation

enum ___VARIABLE_sceneName___Mutation {
    
}

// MARK: - State

@MainActor public struct ___VARIABLE_sceneName___State {
    
    var domainState = DomainState()
    
    struct DomainState {
        
    }
    
    public init() {}
}

// MARK: - Store

protocol ___VARIABLE_sceneName___Mutatable: AnyObject {
    @MainActor func execute(_ mutation: ___VARIABLE_sceneName___Mutation)
}

protocol Has___VARIABLE_sceneName___DomainState: AnyObject {
    @MainActor var domainState: ___VARIABLE_sceneName___State.DomainState { get }
}

@MainActor final class ___VARIABLE_sceneName___Store: ___VARIABLE_sceneName___Mutatable, Has___VARIABLE_sceneName___DomainState, ObservableObject {
    
    let worker: ___VARIABLE_sceneName___Workable
    @Published private(set) var state: ___VARIABLE_sceneName___State
    var domainState: ___VARIABLE_sceneName___State.DomainState { self.state.domainState }
    
    init(
        worker: ___VARIABLE_sceneName___Workable,
        state: ___VARIABLE_sceneName___State
    ) {
        self.worker = worker
        self.state = state
    }
    
    func execute(_ mutation: ___VARIABLE_sceneName___Mutation) {
        self.state = self.execute(state: self.state, mutation: mutation)
    }
}

// MARK: - Implement

extension ___VARIABLE_sceneName___Store {
    
    private func execute(state: ___VARIABLE_sceneName___State, mutation: ___VARIABLE_sceneName___Mutation) -> ___VARIABLE_sceneName___State {
        var state = state
        
        switch mutation {
            
        }
        
        return state
    }
}
