//
//  AddRequestsWorker.swift
//  Example
//
//  Created by 박건우 on 2023/12/21.
//  Copyright (c) 2023 Spoqa. All rights reserved.
//

import NetworkService

import Foundation

// MARK: - Delegate

public protocol AddRequestsDelegate: AnyObject {
    @MainActor func quotationRequestSuccessed(successMessage: String)
}

// MARK: - Worker

protocol AddRequestsWorkable: AnyObject {
    var delegate: AddRequestsDelegate? { get set }
    func requestCreateQuotation(receiptImageUploadUrlObjectKeys: [String], requests: String) async throws
}

final class AddRequestsWorker: AddRequestsWorkable {
    
    weak var delegate: AddRequestsDelegate?
    
    private let quotationNetworkService: QuotationNetworkServiceProtocol
    
    init(
        delegate: AddRequestsDelegate,
        quotationNetworkService: QuotationNetworkServiceProtocol
    ) {
        self.delegate = delegate
        self.quotationNetworkService = quotationNetworkService
    }
}

// MARK: - Implement

extension AddRequestsWorker {
    
    func requestCreateQuotation(receiptImageUploadUrlObjectKeys: [String], requests: String) async throws {
        return try await self.quotationNetworkService.mutateCreateQuotation(
            uploadUrlObjectKeys: receiptImageUploadUrlObjectKeys,
            requests: requests
        )
    }
}
