//
//  AddRequestsSceneTests.swift
//  Example
//
//  Created by 박건우 on 2023/12/21.
//  Copyright (c) 2023 Spoqa. All rights reserved.
//

import XCTest
@testable import AddRequestsScene

class AddRequestsSceneTests: XCTestCase {
    
    var controller: AddRequestsController!
    @MainActor var state: AddRequestsState { self.store.state }
    
    var store: AddRequestsStore!
    var interactor: AddRequestsInteractor!
    
    var mockWorker: MockWorker!
    var mockDelegate: MockDelegate!
    
    @MainActor override func setUp() {
        super.setUp()
        
        self.mockWorker = MockWorker()
        self.mockDelegate = MockDelegate()
        self.mockWorker.delegate = self.mockDelegate
        self.configure(initialState: AddRequestsState(receiptImageUploadUrlObjectKeys: [""]))
    }
    
    @MainActor private func configure(initialState: AddRequestsState) {
        self.store = AddRequestsStore(worker: self.mockWorker, state: initialState)
        self.interactor = AddRequestsInteractor(store: self.store, worker: self.mockWorker)
        self.controller = AddRequestsController(interactor: self.interactor, store: self.store)
    }
    
    override func tearDown() {
        self.controller = nil
        self.store = nil
        self.interactor = nil
        self.mockWorker = nil
        self.mockDelegate = nil
        super.tearDown()
    }
    
    // MARK: - Test Scenarios
    
    func test_요구사항글자변경__요구사항입력됨() async {
        // Given
        
        // When
        await self.controller.execute(.newRequestsTextChanged(newValue: "test")).value
        
        
        // Then
        let domainRequests = await self.state.domainState.requests
        let requestsText = await self.state.requestsText
        
        XCTAssertEqual(domainRequests, "test")
        XCTAssertEqual(requestsText, "test")
    }
    
    func test_견적요청버튼클릭_견적요청성공_성공출력() async {
        // Given
        await MainActor.run {
            self.mockWorker.requestCreateQuotationResult = .success(())
        }
        
        // When
        await self.controller.execute(.quotationRequestButtonTapped).value
        
        // Then
        let lastSuccessMessage = self.mockDelegate.lastSuccessMessage
        
        XCTAssertEqual(lastSuccessMessage, "견적 요청을 성공하였습니다 :)")
    }
    
    func test_견적요청버튼클릭_견적요청실패_실패출력() async {
        // Given
        await MainActor.run {
            self.mockWorker.requestCreateQuotationResult = .failure(NSError(domain: "Test_Error", code: -999))
        }
        
        // When
        await self.controller.execute(.quotationRequestButtonTapped).value
        
        // Then
        let message = await self.state.message
        
        XCTAssertEqual(message, "작업을 완료할 수 없습니다.(Test_Error 오류 -999.)")
    }
}

// MARK: - Mock Classes

extension AddRequestsSceneTests {
    
    class MockWorker: AddRequestsWorkable {
        
        var delegate: AddRequestsDelegate?
        
        var requestCreateQuotationResult: Result<Void, Error>?
        func requestCreateQuotation(receiptImageUploadUrlObjectKeys: [String], requests: String) async throws {
            if let requestCreateQuotationResult = self.requestCreateQuotationResult {
                switch requestCreateQuotationResult {
                case .success(let data):
                    return data
                case .failure(let error):
                    throw error
                }
            }
            XCTFail("requestCreateQuotation()의 결과값을 주입해주어야합니다.")
        }
    }
    
    class MockDelegate: AddRequestsDelegate {
        
        var lastSuccessMessage: String?
        func quotationRequestSuccessed(successMessage: String) {
            self.lastSuccessMessage = successMessage
        }
    }
}
