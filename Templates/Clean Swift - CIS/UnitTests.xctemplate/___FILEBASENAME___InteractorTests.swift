//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright (c) ___YEAR___ Spoqa. All rights reserved.
//

import XCTest
@testable import ___VARIABLE_productName___Scene

class ___VARIABLE_productName___InteractorTests: XCTestCase {
    
    var interactor: ___VARIABLE_productName___Interactor!
    
    var mockStore: MockStore!
    var mockWorker: MockWorker!
    
    override func setUp() {
        super.setUp()
        
        self.mockStore = MockStore()
        self.mockWorker = MockWorker()
        self.interactor = ___VARIABLE_productName___Interactor(store: self.mockStore, worker: self.mockWorker)
    }
    
    override func tearDown() {
        self.interactor = nil
        self.mockStore = nil
        self.mockWorker = nil
        super.tearDown()
    }
    
    // MARK: - Test Cases
    
    // MARK: - Test UseCase
    
    func test_usecase() async {
        // Given
        
        // When
        
        // Then
    }
}

// MARK: - Mock Classes

extension ___VARIABLE_productName___InteractorTests {

    class MockStore: ___VARIABLE_productName___Mutatable, Has___VARIABLE_productName___DomainState {
        @MainActor var domainState = ___VARIABLE_productName___State.DomainState()

        @MainActor func execute(_ mutation: ___VARIABLE_productName___Mutation) {
            switch mutation {
            default:
                break
            }
        }
    }

    class MockWorker: ___VARIABLE_productName___Workable {
        
    }
}
