//
//  AddRequestsSwiftUIView.swift
//  Example
//
//  Created by 박건우 on 2023/12/21.
//  Copyright (c) 2023 Spoqa. All rights reserved.
//

import NetworkService

import SwiftUI

public struct AddRequestsSwiftUIView: View {
    
    private var controller: AddRequestsControllerable
    @ObservedObject private var store: AddRequestsStore
    
    public init(
        initialState: AddRequestsState,
        controller: inout AddRequestsControllerable?,
        delegate: AddRequestsDelegate
    ) {
        let quotationNetworkService = QuotationNetworkService()
        let worker = AddRequestsWorker(delegate: delegate, quotationNetworkService: quotationNetworkService)
        let store = AddRequestsStore(worker: worker, state: initialState)
        let interactor = AddRequestsInteractor(store: store, worker: worker)
        let _controller = AddRequestsController(interactor: interactor, store: store)
        controller = _controller
        
        self.controller = _controller
        self.store = store
    }
    
    public var body: some View {
        VStack {
            TextField("요청 사항 입력", text: Binding(
                get: {
                    return self.store.state.requestsText
                },
                set: { value in
                    self.controller.execute(.newRequestsTextChanged(newValue: value))
                }
            ))
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding(.top, 20)
            .padding(.horizontal, 10)
            
            Text("견적 요청")
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, minHeight: 50)
                .background(Color.blue)
                .cornerRadius(10)
                .padding(.horizontal, 10)
                .onTapGesture {
                    self.controller.execute(.quotationRequestButtonTapped)
                }
            
            Text(self.store.state.message)
            
            Spacer()
        }
        .navigationBarTitle("견적 요청 - 요청 사항", displayMode: .inline)
        .navigationBarBackButtonHidden(false)
    }
}
