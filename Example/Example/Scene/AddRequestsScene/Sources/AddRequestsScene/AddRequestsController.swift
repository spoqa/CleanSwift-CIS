//
//  AddRequestsController.swift
//  Example
//
//  Created by 박건우 on 2023/12/21.
//  Copyright (c) 2023 Spoqa. All rights reserved.
//

import Foundation

// MARK: - Action

public enum AddRequestsAction {
    case newRequestsTextChanged(newValue: String)
    case quotationRequestButtonTapped
}

// MARK: - Controller

public protocol AddRequestsControllerable: AnyObject {
    @discardableResult func execute(_ action: AddRequestsAction) -> Task<Void, Never>
}

final class AddRequestsController: AddRequestsControllerable {
    
    private let interactor: AddRequestsInteractable
    private weak var store: AddRequestsMutatable?
    
    init(
        interactor: AddRequestsInteractable,
        store: AddRequestsMutatable
    ) {
        self.interactor = interactor
        self.store = store
    }
    
    @discardableResult public func execute(_ action: AddRequestsAction) -> Task<Void, Never> {
        Task { [weak self] in
            await self?.execute(action)
        }
    }
}

// MARK: - Implement

extension AddRequestsController {
    
    private func execute(_ action: AddRequestsAction) async {
        switch action {
        case .newRequestsTextChanged(let newValue):
            await self.store?.execute(.setRequests(requests: newValue))
            
        case .quotationRequestButtonTapped:
            await self.interactor.execute(.requestQuotation(request: AddRequests.RequestQuotation.Request()))
        }
    }
}
