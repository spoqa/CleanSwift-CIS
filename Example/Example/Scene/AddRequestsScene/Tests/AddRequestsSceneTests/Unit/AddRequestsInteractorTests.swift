//
//  AddRequestsInteractorTests.swift
//  Example
//
//  Created by 박건우 on 2024/01/23.
//  Copyright (c) 2023 Spoqa. All rights reserved.
//

import XCTest
@testable import AddRequestsScene

class AddRequestsInteractorTests: XCTestCase {
    
    var interactor: AddRequestsInteractor!
    
    var mockStore: MockStore!
    var mockWorker: MockWorker!
    
    override func setUp() {
        super.setUp()
        
        self.mockStore = MockStore()
        self.mockWorker = MockWorker()
        self.interactor = AddRequestsInteractor(store: self.mockStore, worker: self.mockWorker)
    }
    
    override func tearDown() {
        self.interactor = nil
        self.mockStore = nil
        self.mockWorker = nil
        super.tearDown()
    }
    
    // MARK: - Test Cases
    
    // MARK: - Test RequestQuotation UseCase
    
    func test_requestQuotation__worker_requestCreateQuotation_호출() async {
        // Given
        let dummyRequest = AddRequests.RequestQuotation.Request()
        
        // When
        await self.interactor.execute(.requestQuotation(request: dummyRequest))
        
        // Then
        XCTAssertTrue(self.mockWorker.isRequestCreateQuotationCalled)
    }
    
    func test_requestQuotation__worker_requestCreateQuotation_성공이면__error_nil_반환() async {
        // Given
        let dummyRequest = AddRequests.RequestQuotation.Request()
        await MainActor.run {
            self.mockWorker.requestCreateQuotationError = nil
        }
        
        // When
        await self.interactor.execute(.requestQuotation(request: dummyRequest))
        
        // Then
        XCTAssertNil(self.mockStore.mutateRequestQuotationResponse?.error)
    }
    
    func test_requestQuotation__worker_requestCreateQuotation_실패이면__error_반환() async {
        // Given
        let dummyRequest = AddRequests.RequestQuotation.Request()
        await MainActor.run {
            self.mockWorker.requestCreateQuotationError = NSError(domain: "Test_Error", code: -999, userInfo: nil)
        }
        
        // When
        await self.interactor.execute(.requestQuotation(request: dummyRequest))
        
        // Then
        XCTAssertNotNil(self.mockStore.mutateRequestQuotationResponse?.error)
    }
}

// MARK: - Mock Classes

extension AddRequestsInteractorTests {
    
    class MockStore: AddRequestsMutatable, HasAddRequestsDomainState {
        @MainActor var domainState = AddRequestsState.DomainState(receiptImageUploadUrlObjectKeys: [])
        
        var mutateRequestQuotationResponse: AddRequests.RequestQuotation.Response?
        
        @MainActor func execute(_ mutation: AddRequestsMutation) {
            switch mutation {
            case .mutateRequestQuotation(let response):
                self.mutateRequestQuotationResponse = response
                
            default:
                break
            }
        }
    }
    
    class MockWorker: AddRequestsWorkable {
        var delegate: AddRequestsDelegate?
        
        var isRequestCreateQuotationCalled = false
        var requestCreateQuotationError: Error?
        
        func requestCreateQuotation(receiptImageUploadUrlObjectKeys: [String], requests: String) async throws {
            self.isRequestCreateQuotationCalled = true
            if let error = self.requestCreateQuotationError {
                throw error
            }
        }
    }
}
