//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright (c) ___YEAR___ Spoqa. All rights reserved.
//

import SwiftUI

public struct ___VARIABLE_productName___View: View {
    
    private let controller: ___VARIABLE_productName___Controllerable
    @ObservedObject private var store: ___VARIABLE_productName___Store
    
    public init(
        initialState: ___VARIABLE_productName___State,
        controller: inout ___VARIABLE_productName___Controllerable?
    ) {
        let worker = ___VARIABLE_productName___Worker()
        let store = ___VARIABLE_productName___Store(worker: worker, state: initialState)
        let interactor = ___VARIABLE_productName___Interactor(store: store, worker: worker)
        let _controller = ___VARIABLE_productName___Controller(interactor: interactor, store: store)
        controller = _controller
        
        self.controller = _controller
        self.store = store
    }
    
    public var body: some View {
        VStack {
            
        }
    }
}
