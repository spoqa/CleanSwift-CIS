//
//  AddRequestsUIKitView.swift
//  
//
//  Created by 박건우 on 2024/01/16.
//

import NetworkService

import UIKit
import Combine

public final class AddRequestsUIKitView: UIViewController {
    public typealias ActiveClosure = (_ isActive: Bool) -> Void
    
    private var cancellables: Set<AnyCancellable> = []

    private let controller: AddRequestsControllerable
    private var store: AddRequestsStore
    private let activeClosure: ActiveClosure

    public init(
        initialState: AddRequestsState,
        controller: inout AddRequestsControllerable?,
        delegate: AddRequestsDelegate,
        activeClosure: @escaping ActiveClosure
    ) {
        let quotationNetworkService = QuotationNetworkService()
        let worker = AddRequestsWorker(delegate: delegate, quotationNetworkService: quotationNetworkService)
        let store = AddRequestsStore(worker: worker, state: initialState)
        let interactor = AddRequestsInteractor(store: store, worker: worker)
        let _controller = AddRequestsController(interactor: interactor, store: store)
        controller = _controller
        
        self.controller = _controller
        self.store = store
        self.activeClosure = activeClosure
        
        super.init(nibName: nil, bundle: nil)
        
        self.bind()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        self.activeClosure(false)
    }
    
    // MARK: - UI
    
    private var textField = UITextField()
    private var requestButton = UIButton()
    private var messageLabel = UILabel()
    
    // MARK: - View lifecycle

    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
    }
    
    // MARK: - Layout

    private func setupUI() {
        self.view.backgroundColor = .white

        // Navigation Setup
        self.title = "견적 요청 - 요청 사항"
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        // TextField Setup
        self.textField.translatesAutoresizingMaskIntoConstraints = false
        self.textField.delegate = self
        self.textField.borderStyle = .roundedRect
        self.textField.placeholder = "요청 사항 입력"
        self.view.addSubview(self.textField)

        // Request Button Setup
        self.requestButton.translatesAutoresizingMaskIntoConstraints = false
        self.requestButton.setTitle("견적 요청", for: .normal)
        self.requestButton.backgroundColor = .blue
        self.requestButton.layer.cornerRadius = 10
        self.requestButton.addTarget(self, action: #selector(self.requestButtonTapped), for: .touchUpInside)
        self.view.addSubview(self.requestButton)

        // Message Label Setup
        self.messageLabel.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.messageLabel)

        // Auto Layout Constraints
        NSLayoutConstraint.activate([
            self.textField.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 20),
            self.textField.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10),
            self.textField.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10),

            self.requestButton.topAnchor.constraint(equalTo: self.textField.bottomAnchor, constant: 20),
            self.requestButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10),
            self.requestButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10),
            self.requestButton.heightAnchor.constraint(equalToConstant: 50),

            self.messageLabel.topAnchor.constraint(equalTo: self.requestButton.bottomAnchor, constant: 20),
            self.messageLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10),
            self.messageLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10)
        ])
    }

    private func bind() {
        
        self.store.$state
            .map { $0.requestsText }
            .sink { requestsText in
                _ = requestsText
            }
            .store(in: &self.cancellables)
        
        self.store.$state
            .map { $0.message }
            .sink { [weak self] message in
                self?.messageLabel.text = message
            }
            .store(in: &self.cancellables)
    }
    
    // MARK: - Action Selector

    @objc private func requestButtonTapped() {
        self.controller.execute(.quotationRequestButtonTapped)
    }
}

extension AddRequestsUIKitView: UITextFieldDelegate {
    
    public func textFieldDidChangeSelection(_ textField: UITextField) {
        self.controller.execute(.newRequestsTextChanged(newValue: textField.text ?? ""))
    }
}
