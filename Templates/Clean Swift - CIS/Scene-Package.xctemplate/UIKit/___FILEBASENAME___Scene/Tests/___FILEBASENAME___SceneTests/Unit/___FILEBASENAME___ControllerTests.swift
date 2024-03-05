//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright (c) ___YEAR___ Spoqa. All rights reserved.
//

import XCTest
@testable import ___VARIABLE_sceneName___Scene

class ___VARIABLE_sceneName___ControllerTests: XCTestCase {
    
    var controller: ___VARIABLE_sceneName___Controller!
    
    var mockInteractor: MockInteractor!
    var mockStore: MockStore!
    
    override func setUp() {
        super.setUp()
        
        self.mockInteractor = MockInteractor()
        self.mockStore = MockStore()
        self.controller = ___VARIABLE_sceneName___Controller(interactor: self.mockInteractor, store: self.mockStore)
    }
    
    override func tearDown() {
        self.controller = nil
        self.mockInteractor = nil
        self.mockStore = nil
        super.tearDown()
    }
    
    // MARK: - Test Cases
    
    func test_action() async {
        // Given
        
        // When
        
        // Then
    }
}

// MARK: - Mock Classes

extension ___VARIABLE_sceneName___ControllerTests {

    class MockInteractor: ___VARIABLE_sceneName___Interactable {
        
        func execute(_ useCase: ___VARIABLE_sceneName___UseCase) async {
            switch useCase {
                
            }
        }
    }

    class MockStore: ___VARIABLE_sceneName___Mutatable {

        @MainActor func execute(_ mutation: ___VARIABLE_sceneName___Mutation) {
            switch mutation {
            default:
                break
            }
        }
    }
}
