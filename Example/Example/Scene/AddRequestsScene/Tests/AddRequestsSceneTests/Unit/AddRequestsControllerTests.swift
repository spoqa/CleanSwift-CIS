//
//  AddRequestsControllerTests.swift
//  Example
//
//  Created by 박건우 on 2024/01/23.
//  Copyright (c) 2023 Spoqa. All rights reserved.
//

import XCTest
@testable import AddRequestsScene

class AddRequestsControllerTests: XCTestCase {
    
    var controller: AddRequestsController!
    
    var mockInteractor: MockInteractor!
    var mockStore: MockStore!
    
    override func setUp() {
        super.setUp()
        
        self.mockInteractor = MockInteractor()
        self.mockStore = MockStore()
        self.controller = AddRequestsController(interactor: self.mockInteractor, store: self.mockStore)
    }
    
    override func tearDown() {
        self.controller = nil
        self.mockInteractor = nil
        self.mockStore = nil
        super.tearDown()
    }
    
    // MARK: - Test Cases
    
    func test_newRequestsTextChanged() async {
        // Given
        let dummyNewRequestsText = "test"
        
        // When
        await self.controller.execute(.newRequestsTextChanged(newValue: dummyNewRequestsText)).value
        
        // Then
        XCTAssertTrue(self.mockStore.isSetRequestsCalled)
    }
    
    func test_quotationRequestButtonTapped() async {
        // Given
        
        // When
        await self.controller.execute(.quotationRequestButtonTapped).value
        
        // Then
        XCTAssertTrue(self.mockInteractor.isRequestQuotationCalled)
    }
}

// MARK: - Mock Classes

extension AddRequestsControllerTests {
    
    class MockInteractor: AddRequestsInteractable {
        var isRequestQuotationCalled = false
        
        func execute(_ useCase: AddRequestsUseCase) async {
            switch useCase {
            case .requestQuotation:
                self.isRequestQuotationCalled = true
            }
        }
    }
    
    class MockStore: AddRequestsMutatable {
        var isSetRequestsCalled = false
        
        @MainActor func execute(_ mutation: AddRequestsMutation) {
            switch mutation {
            case .setRequests:
                self.isSetRequestsCalled = true
                
            default:
                break
            }
        }
    }
}
