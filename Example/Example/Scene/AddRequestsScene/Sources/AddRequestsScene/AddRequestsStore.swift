//
//  AddRequestsStore.swift
//  Example
//
//  Created by 박건우 on 2023/12/21.
//  Copyright (c) 2023 Spoqa. All rights reserved.
//

import Foundation

// MARK: - Mutation

enum AddRequestsMutation {
    case mutateRequestQuotation(response: AddRequests.RequestQuotation.Response)
    
    case setRequests(requests: String)
}

// MARK: - State

@MainActor public struct AddRequestsState {
    var requestsText: String = ""
    var message: String = ""
    
    var domainState: DomainState
    
    struct DomainState {
        var receiptImageUploadUrlObjectKeys: [String]
        var requests: String = ""
    }
    
    public init(receiptImageUploadUrlObjectKeys: [String]) {
        self.domainState = DomainState(receiptImageUploadUrlObjectKeys: receiptImageUploadUrlObjectKeys)
    }
}

// MARK: - Store

protocol AddRequestsMutatable: AnyObject {
    @MainActor func execute(_ mutation: AddRequestsMutation)
}

protocol HasAddRequestsDomainState: AnyObject {
    @MainActor var domainState: AddRequestsState.DomainState { get }
}

@MainActor final class AddRequestsStore: AddRequestsMutatable, HasAddRequestsDomainState, ObservableObject {
    
    let worker: AddRequestsWorkable
    @Published private(set) var state: AddRequestsState
    var domainState: AddRequestsState.DomainState { self.state.domainState }
    
    init(
        worker: AddRequestsWorkable,
        state: AddRequestsState
    ) {
        self.worker = worker
        self.state = state
    }
    
    func execute(_ mutation: AddRequestsMutation) {
        self.state = self.execute(state: self.state, mutation: mutation)
    }
}

// MARK: - Implement

extension AddRequestsStore {
    
    func execute(state: AddRequestsState, mutation: AddRequestsMutation) -> AddRequestsState {
        var state = state
        
        switch mutation {
        case .mutateRequestQuotation(let response):
            if let error = response.error {
                state.message = error.localizedDescription
            }
            else {
                self.worker.delegate?.quotationRequestSuccessed(successMessage: "견적 요청을 성공하였습니다 :)")
            }
            
        case .setRequests(let requests):
            state.domainState.requests = requests
            state.requestsText = requests
        }
        
        return state
    }
}
