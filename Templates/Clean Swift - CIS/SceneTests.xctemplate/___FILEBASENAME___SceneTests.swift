//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright (c) ___YEAR___ Spoqa. All rights reserved.
//

import XCTest
@testable import ___VARIABLE_productName___Scene

class ___VARIABLE_productName___SceneTests: XCTestCase {
    
    var controller: ___VARIABLE_productName___Controller!
    @MainActor var state: ___VARIABLE_productName___State { self.store.state }
    
    var store: ___VARIABLE_productName___Store!
    var interactor: ___VARIABLE_productName___Interactor!
    
    var mockWorker: MockWorker!
    
    @MainActor override func setUp() {
        super.setUp()
        
        self.mockWorker = MockWorker()
        self.configure(initialState: ___VARIABLE_productName___State())
    }
    
    @MainActor private func configure(initialState: ___VARIABLE_productName___State) {
        self.store = ___VARIABLE_productName___Store(worker: self.mockWorker, state: initialState)
        self.interactor = ___VARIABLE_productName___Interactor(store: self.store, worker: self.mockWorker)
        self.controller = ___VARIABLE_productName___Controller(interactor: self.interactor, store: self.store)
    }
    
    override func tearDown() {
        self.controller = nil
        self.store = nil
        self.interactor = nil
        self.mockWorker = nil
        super.tearDown()
    }
    
    // MARK: - Test Scenarios
    
    func test_scenario() async {
        // Given
        
        // When
        
        // Then
    }
}

// MARK: - Mock Classes

extension ___VARIABLE_productName___SceneTests {
    
    class MockWorker: ___VARIABLE_productName___Workable {
        
    }
}
