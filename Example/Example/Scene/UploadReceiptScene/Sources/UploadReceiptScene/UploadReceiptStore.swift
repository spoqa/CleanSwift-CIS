//
//  UploadReceiptStore.swift
//  Example
//
//  Created by 박건우 on 2023/12/21.
//  Copyright (c) 2023 Spoqa. All rights reserved.
//

import AddRequestsScene

import Foundation

// MARK: - Mutation

enum UploadReceiptMutation {
    case mutateAttachImage(response: UploadReceipt.AttachImage.Response)
    case mutateUploadImage(response: UploadReceipt.UploadImage.Response)
    case mutateSaveImage(response: UploadReceipt.SaveImage.Response)
    case mutateShowCamera(response: UploadReceipt.ShowCamera.Response)
    case mutateShowGallery(response: UploadReceipt.ShowGallery.Response)
    
    case showSelectImageAttachmentMethodSheet
    case dismissSelectImageAttachmentMethodSheet
    case dismissCamera
    case dismissImagePicker
    case showMessage(message: String)
    case clearAttachedImages
    case setIsActiveAddRequestsView(isActive: Bool)
}

// MARK: - State

@MainActor public struct UploadReceiptState {
    var attachedImages: [UploadReceipt.ImageUIDataModel] = []
    var showingSelectImageAttachmentMethodSheet: Bool = false
    var showingImagePicker: Bool = false
    var showingCamera: Bool = false
    var isAddRequestsViewActive: Bool = false
    var receiptImageUploadUrlObjectKeys: [String] = []
    
    var domainState = DomainState()
    
    struct DomainState {
        var attachedImages: [UploadReceipt.ImageModel] = []
    }
    
    public init() {}
}

// MARK: - Store

protocol UploadReceiptMutatable: AnyObject {
    @MainActor func execute(_ mutation: UploadReceiptMutation)
}

protocol HasUploadReceiptDomainState: AnyObject {
    @MainActor var domainState: UploadReceiptState.DomainState { get }
}

@MainActor final class UploadReceiptStore: UploadReceiptMutatable, HasUploadReceiptDomainState, ObservableObject {
    
    let worker: UploadReceiptWorkable
    @Published private(set) var state: UploadReceiptState
    var domainState: UploadReceiptState.DomainState { self.state.domainState }
    
    init(
        worker: UploadReceiptWorkable,
        state: UploadReceiptState
    ) {
        self.worker = worker
        self.state = state
    }
    
    func execute(_ mutation: UploadReceiptMutation) {
        self.state = self.execute(state: self.state, mutation: mutation)
    }
}

// MARK: - Implement
extension UploadReceiptStore {
    
    private func execute(state: UploadReceiptState, mutation: UploadReceiptMutation) -> UploadReceiptState {
        var state = state
        
        switch mutation {
        case .mutateAttachImage(let response):
            if let error = response.error {
                switch error {
                case .exceedImageCount:
                    self.worker.showToast(message: "최대 5장까지 첨부할 수 있습니다")
                    
                case .failDataMapping:
                    self.worker.showToast(message: "사진 처리 과정에서 오류가 발생하였습니다")
                }
            }
            else {
                state.domainState.attachedImages = response.attachedImages
                state.attachedImages = response.attachedImages.map { $0.uiData }
            }
            
        case .mutateUploadImage(let response):
            if let error = response.error {
                switch error {
                case .emptyAttachedImage:
                    self.worker.showToast(message: "견적 요청을 하기 위해서\n필수로 이미지를 첨부하여야 합니다")
                    
                case .default(let error):
                    self.worker.showToast(message: error.localizedDescription)
                }
            }
            else {
                state.receiptImageUploadUrlObjectKeys = response.uploadUrlObjectKeys // Data Passing
                state.isAddRequestsViewActive = true // Active AddRequests View
            }
            
        case .mutateSaveImage(let response):
            if let error = response.error {
                self.worker.showToast(message: error.localizedDescription)
            }
            
        case .mutateShowCamera(let response):
            if response.permissionDenied {
                self.worker.showToast(message: "명세표를 업로드하기 위해서\n카메라 및 모든 사진 접근 권한이 필요합니다")
            }
            state.showingCamera = !response.permissionDenied
            
        case .mutateShowGallery(let response):
            if response.permissionDenied {
                self.worker.showToast(message: "명세표를 업로드하기 위해서\n 모든 사진 접근 권한이 필요합니다")
            }
            state.showingImagePicker = !response.permissionDenied
            
        case .showSelectImageAttachmentMethodSheet:
            state.showingSelectImageAttachmentMethodSheet = true
            
        case .dismissSelectImageAttachmentMethodSheet:
            state.showingSelectImageAttachmentMethodSheet = false
            
        case .dismissCamera:
            state.showingCamera = false
            
        case .dismissImagePicker:
            state.showingImagePicker = false
            
        case .showMessage(let message):
            self.worker.showToast(message: message)
            
        case .clearAttachedImages:
            state.attachedImages = []
            state.domainState.attachedImages = []
            
        case .setIsActiveAddRequestsView(let isActive):
            state.isAddRequestsViewActive = isActive
        }
        
        return state
    }
}
