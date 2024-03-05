//
//  QuotationNetworkService.swift
//  
//
//  Created by 박건우 on 2023/12/26.
//

import Foundation

public protocol QuotationNetworkServiceProtocol {
    func mutateCreateQuotation(uploadUrlObjectKeys: [String], requests: String?) async throws
}

public final class QuotationNetworkService: QuotationNetworkServiceProtocol {
    
    public init() {}
    
    public func mutateCreateQuotation(uploadUrlObjectKeys: [String], requests: String?) async throws {
        
    }
}
