//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright (c) ___YEAR___ Spoqa. All rights reserved.
//

import XCTest
@testable import ___VARIABLE_sceneName___Scene

class ___VARIABLE_sceneName___SceneTests: XCTestCase {
    
    var controller: ___VARIABLE_sceneName___Controller!
    @MainActor var state: ___VARIABLE_sceneName___State { self.store.state }
    
    var store: ___VARIABLE_sceneName___Store!
    var interactor: ___VARIABLE_sceneName___Interactor!
    
    var mockWorker: MockWorker!
    
    @MainActor override func setUp() {
        super.setUp()
        
        self.mockWorker = MockWorker()
        self.configure(initialState: ___VARIABLE_sceneName___State())
    }
    
    @MainActor private func configure(initialState: ___VARIABLE_sceneName___State) {
        self.store = ___VARIABLE_sceneName___Store(worker: self.mockWorker, state: initialState)
        self.interactor = ___VARIABLE_sceneName___Interactor(store: self.store, worker: self.mockWorker)
        self.controller = ___VARIABLE_sceneName___Controller(interactor: self.interactor, store: self.store)
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

extension ___VARIABLE_sceneName___SceneTests {
    
    class MockWorker: ___VARIABLE_sceneName___Workable {
        
    }
}
