//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright (c) ___YEAR___ Spoqa. All rights reserved.
//

import Combine
import UIKit

public final class ___VARIABLE_sceneName___View: UIViewController {
    private var cancellables: Set<AnyCancellable> = []
    
    private let controller: ___VARIABLE_sceneName___Controllerable
    private var store: ___VARIABLE_sceneName___Store
    
    public init(
        initialState: ___VARIABLE_sceneName___State,
        controller: inout ___VARIABLE_sceneName___Controllerable?
    ) {
        let worker = ___VARIABLE_sceneName___Worker()
        let store = ___VARIABLE_sceneName___Store(worker: worker, state: initialState)
        let interactor = ___VARIABLE_sceneName___Interactor(store: store, worker: worker)
        let _controller = ___VARIABLE_sceneName___Controller(interactor: interactor, store: store)
        controller = _controller
        
        self.controller = _controller
        self.store = store
        
        super.init(nibName: nil, bundle: nil)
        
        self.bind()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI
    
    // MARK: - View lifecycle
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
    }
    
    // MARK: - Layout
    
    private func setupUI() {
        
    }
    
    // MARK: - Bind
    
    private func bind() {
        
    }
}
