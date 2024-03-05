//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright (c) ___YEAR___ Spoqa. All rights reserved.
//

import Foundation

// MARK: - Action

public enum ___VARIABLE_sceneName___Action {
    
}

// MARK: - Controller

public protocol ___VARIABLE_sceneName___Controllerable: AnyObject {
    @discardableResult func execute(_ action: ___VARIABLE_sceneName___Action) -> Task<Void, Never>
}

final class ___VARIABLE_sceneName___Controller: ___VARIABLE_sceneName___Controllerable {
    
    private let interactor: ___VARIABLE_sceneName___Interactable
    private weak var store: ___VARIABLE_sceneName___Mutatable?
    
    init(
        interactor: ___VARIABLE_sceneName___Interactable,
        store: ___VARIABLE_sceneName___Mutatable
    ) {
        self.interactor = interactor
        self.store = store
    }
    
    @discardableResult public func execute(_ action: ___VARIABLE_sceneName___Action) -> Task<Void, Never> {
        Task { [weak self] in
            await self?.execute(action)
        }
    }
}

// MARK: - Implement

extension ___VARIABLE_sceneName___Controller {
    
    private func execute(_ action: ___VARIABLE_sceneName___Action) async {
        switch action {
            
        }
    }
}
