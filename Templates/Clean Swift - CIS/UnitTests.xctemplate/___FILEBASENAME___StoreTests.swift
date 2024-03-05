//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright (c) ___YEAR___ Spoqa. All rights reserved.
//

import XCTest
@testable import ___VARIABLE_productName___Scene

@MainActor class ___VARIABLE_productName___StoreTests: XCTestCase {
    
    var store: ___VARIABLE_productName___Store!
    @MainActor var state: ___VARIABLE_productName___State { self.store.state }
    
    var mockWorker: MockWorker!
    
    override func setUp() {
        super.setUp()
        
        self.mockWorker = MockWorker()
        self.configure(initialState: ___VARIABLE_productName___State())
    }
    
    private func configure(initialState: ___VARIABLE_productName___State) {
        self.store = ___VARIABLE_productName___Store(worker: self.mockWorker, state: initialState)
    }
    
    override func tearDown() {
        self.store = nil
        self.mockWorker = nil
        super.tearDown()
    }
    
    // MARK: - Test Cases
    
    func test_mutation() {
        // Given
        
        // When
        
        // Then
    }
}

// MARK: - Mock Classes

extension ___VARIABLE_productName___StoreTests {
    
    class MockWorker: ___VARIABLE_productName___Workable {
        
    }
}
