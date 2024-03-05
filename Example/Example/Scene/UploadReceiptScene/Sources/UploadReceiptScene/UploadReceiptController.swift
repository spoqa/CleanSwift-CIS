//
//  UploadReceiptController.swift
//  Example
//
//  Created by 박건우 on 2023/12/21.
//  Copyright (c) 2023 Spoqa. All rights reserved.
//

import AddRequestsScene

import Foundation

// MARK: - Action

public enum UploadReceiptAction {
    case imageAttachTapped
    case imageAttachmentMethodCameraSelected
    case imageAttachmentMethodGallerySelected
    case cameraCanceled
    case cameraPhotoTakenCompleted(image: UploadReceipt.ImageUIDataModel)
    case imagePickerCanceled
    case imagePicked(image: UploadReceipt.ImageUIDataModel)
    case nextButtonTapped
    case addRequestsViewIsActiveChanged(isActive: Bool)
}

// MARK: - Controller

public protocol UploadReceiptControllerable: AnyObject {
    @discardableResult func execute(_ action: UploadReceiptAction) -> Task<Void, Never>
}

final class UploadReceiptController: UploadReceiptControllerable {
    
    private let interactor: UploadReceiptInteractable
    private weak var store: UploadReceiptMutatable?
    
    init(
        interactor: UploadReceiptInteractable,
        store: UploadReceiptMutatable
    ) {
        self.interactor = interactor
        self.store = store
    }
    
    @discardableResult public func execute(_ action: UploadReceiptAction) -> Task<Void, Never> {
        Task { [weak self] in
            await self?.execute(action)
        }
    }
}

// MARK: - Implement

extension UploadReceiptController {
    
    private func execute(_ action: UploadReceiptAction) async {
        switch action {
        case .imageAttachTapped:
            await self.store?.execute(.showSelectImageAttachmentMethodSheet)
            
        case .imageAttachmentMethodCameraSelected:
            await self.store?.execute(.dismissSelectImageAttachmentMethodSheet)
            await self.interactor.execute(.showCamera(request: UploadReceipt.ShowCamera.Request()))
            
        case .imageAttachmentMethodGallerySelected:
            await self.store?.execute(.dismissSelectImageAttachmentMethodSheet)
            await self.interactor.execute(.showGallery(request: UploadReceipt.ShowGallery.Request()))
            
        case .cameraCanceled:
            await self.store?.execute(.dismissCamera)
            
        case .cameraPhotoTakenCompleted(let image):
            await self.interactor.execute(.saveImage(request: UploadReceipt.SaveImage.Request(imageUIData: image)))
            await self.interactor.execute(.attachImage(request: UploadReceipt.AttachImage.Request(imageUIData: image)))
            await self.store?.execute(.dismissCamera)
            
        case .imagePickerCanceled:
            await self.store?.execute(.dismissImagePicker)
            
        case .imagePicked(let image):
            await self.interactor.execute(.attachImage(request: UploadReceipt.AttachImage.Request(imageUIData: image)))
            await self.store?.execute(.dismissImagePicker)
            
        case .nextButtonTapped:
            await self.interactor.execute(.uploadImage(request: UploadReceipt.UploadImage.Request()))
            
        case .addRequestsViewIsActiveChanged(let isActive):
            await self.store?.execute(.setIsActiveAddRequestsView(isActive: isActive))
        }
    }
}

// MARK: - Implement AddRequests Scene Delegate

extension UploadReceiptController: AddRequestsDelegate {
    
    @MainActor func quotationRequestSuccessed(successMessage: String) {
        self.store?.execute(.setIsActiveAddRequestsView(isActive: false))
        self.store?.execute(.showMessage(message: successMessage))
        self.store?.execute(.clearAttachedImages)
    }
}
