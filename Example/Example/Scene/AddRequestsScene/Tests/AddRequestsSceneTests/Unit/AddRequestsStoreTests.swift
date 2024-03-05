//
//  AddRequestsStoreTests.swift
//  Example
//
//  Created by 박건우 on 2024/01/23.
//  Copyright (c) 2023 Spoqa. All rights reserved.
//

import XCTest
@testable import AddRequestsScene

@MainActor class AddRequestsStoreTests: XCTestCase {
    
    var store: AddRequestsStore!
    @MainActor var state: AddRequestsState { self.store.state }
    
    var mockWorker: MockWorker!
    var mockDelegate: MockDelegate!
    
    override func setUp() {
        super.setUp()
        
        self.mockWorker = MockWorker()
        self.mockDelegate = MockDelegate()
        self.mockWorker.delegate = self.mockDelegate
        self.configure(initialState: AddRequestsState(receiptImageUploadUrlObjectKeys: [""]))
    }
    
    private func configure(initialState: AddRequestsState) {
        self.store = AddRequestsStore(worker: self.mockWorker, state: initialState)
    }
    
    override func tearDown() {
        self.store = nil
        self.mockWorker = nil
        super.tearDown()
    }
    
    // MARK: - Test Cases
    
    func test_mutateRequestQuotation__error() {
        // Given
        let dummyResponse = AddRequests.RequestQuotation.Response(error: NSError(domain: "Test_Error", code: -999, userInfo: nil))
        
        // When
        self.store.execute(.mutateRequestQuotation(response: dummyResponse))
        
        // Then
        XCTAssertEqual(self.state.message, "작업을 완료할 수 없습니다.(Test_Error 오류 -999.)")
    }
    
    func test_mutateRequestQuotation__success() {
        // Given
        let dummyResponse = AddRequests.RequestQuotation.Response(error: nil)
        
        // When
        self.store.execute(.mutateRequestQuotation(response: dummyResponse))
        
        // Then
        XCTAssertEqual(self.mockDelegate.lastSuccessMessage, "견적 요청을 성공하였습니다 :)")
    }
    
    func test_setRequests() {
        // Given
        let dummyRequests = "test"
        
        // When
        self.store.execute(.setRequests(requests: dummyRequests))
        
        // Then
        XCTAssertEqual(self.state.domainState.requests, dummyRequests)
        XCTAssertEqual(self.state.requestsText, dummyRequests)
    }
}

// MARK: - Mock Classes

extension AddRequestsStoreTests {
    
    class MockWorker: AddRequestsWorkable {
        
        var delegate: AddRequestsDelegate?
        
        func requestCreateQuotation(receiptImageUploadUrlObjectKeys: [String], requests: String) async throws {
            return
        }
    }
    
    class MockDelegate: AddRequestsDelegate {
        
        var lastSuccessMessage: String?
        func quotationRequestSuccessed(successMessage: String) {
            self.lastSuccessMessage = successMessage
        }
    }
}
