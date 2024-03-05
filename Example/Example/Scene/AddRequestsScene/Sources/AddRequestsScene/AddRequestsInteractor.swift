//
//  AddRequestsInteractor.swift
//  Example
//
//  Created by 박건우 on 2023/12/21.
//  Copyright (c) 2023 Spoqa. All rights reserved.
//

import Foundation

// MARK: - UseCase

enum AddRequestsUseCase {
    case requestQuotation(request: AddRequests.RequestQuotation.Request)
}

// MARK: - Interactor

protocol AddRequestsInteractable {
    func execute(_ useCase: AddRequestsUseCase) async
}

final class AddRequestsInteractor: AddRequestsInteractable {
    
    private let store: AddRequestsMutatable & HasAddRequestsDomainState
    private let worker: AddRequestsWorkable
    
    init(
        store: AddRequestsMutatable & HasAddRequestsDomainState,
        worker: AddRequestsWorkable
    ) {
        self.store = store
        self.worker = worker
    }
}

// MARK: - Implement

extension AddRequestsInteractor {
    
    func execute(_ useCase: AddRequestsUseCase) async {
        switch useCase {
        case .requestQuotation(_):
            let response: AddRequests.RequestQuotation.Response
            let storedReceiptImageUploadUrlObjectKeys = await self.store.domainState.receiptImageUploadUrlObjectKeys
            let storedRequests = await self.store.domainState.requests
            
            do {
                try await self.worker.requestCreateQuotation(
                    receiptImageUploadUrlObjectKeys: storedReceiptImageUploadUrlObjectKeys,
                    requests: storedRequests
                )
                response = AddRequests.RequestQuotation.Response(error: nil)
            }
            catch {
                response = AddRequests.RequestQuotation.Response(error: error)
            }
            
            await self.store.execute(.mutateRequestQuotation(response: response))
        }
    }
}
