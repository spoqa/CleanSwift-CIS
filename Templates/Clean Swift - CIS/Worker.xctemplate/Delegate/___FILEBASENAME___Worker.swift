//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright (c) ___YEAR___ Spoqa. All rights reserved.
//

import Foundation

// MARK: - Delegate

public protocol ___VARIABLE_productName___Delegate: AnyObject {
}

// MARK: - Worker

protocol ___VARIABLE_productName___Workable: AnyObject {
    var delegate: ___VARIABLE_productName___Delegate? { get set }
    
}

final class ___VARIABLE_productName___Worker: ___VARIABLE_productName___Workable {
    
    weak var delegate: ___VARIABLE_productName___Delegate?
    
    init(delegate: ___VARIABLE_productName___Delegate) {
        self.delegate = delegate
    }
}

// MARK: - Implement

extension ___VARIABLE_productName___Worker {
    
}
