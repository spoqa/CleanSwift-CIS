//
//  UploadReceiptInteractor.swift
//  Example
//
//  Created by 박건우 on 2023/12/21.
//  Copyright (c) 2023 Spoqa. All rights reserved.
//

import Foundation

// MARK: - UseCase

enum UploadReceiptUseCase {
    case attachImage(request: UploadReceipt.AttachImage.Request)
    case uploadImage(request: UploadReceipt.UploadImage.Request)
    case saveImage(request: UploadReceipt.SaveImage.Request)
    case showCamera(request: UploadReceipt.ShowCamera.Request)
    case showGallery(request: UploadReceipt.ShowGallery.Request)
}

// MARK: - Interactor

protocol UploadReceiptInteractable {
    func execute(_ useCase: UploadReceiptUseCase) async
}

final class UploadReceiptInteractor: UploadReceiptInteractable {
    
    private let store: UploadReceiptMutatable & HasUploadReceiptDomainState
    private let worker: UploadReceiptWorkable
    
    init(
        store: UploadReceiptMutatable & HasUploadReceiptDomainState,
        worker: UploadReceiptWorkable
    ) {
        self.store = store
        self.worker = worker
    }
}

// MARK: - Implement

extension UploadReceiptInteractor {
    
    func execute(_ useCase: UploadReceiptUseCase) async {
        switch useCase {
        case .attachImage(let request):
            let response: UploadReceipt.AttachImage.Response
            let storedAttachedImages = await self.store.domainState.attachedImages
            
            if storedAttachedImages.count >= 5 {
                response = UploadReceipt.AttachImage.Response(
                    attachedImages: storedAttachedImages,
                    error: .exceedImageCount
                )
            }
            else if let imageData = self.worker.mapToData(from: request.imageUIData) {
                response =  UploadReceipt.AttachImage.Response(
                    attachedImages: storedAttachedImages + [UploadReceipt.ImageModel(data: imageData, uiData: request.imageUIData)],
                    error: nil
                )
            }
            else {
                response = UploadReceipt.AttachImage.Response(
                    attachedImages: storedAttachedImages,
                    error: .failDataMapping
                )
            }
            
            await self.store.execute(.mutateAttachImage(response: response))
            
        case .uploadImage(_):
            let response: UploadReceipt.UploadImage.Response
            let storedAttachedImages = await self.store.domainState.attachedImages
            
            if storedAttachedImages.isEmpty {
                response =  UploadReceipt.UploadImage.Response(
                    uploadUrlObjectKeys: [],
                    error: .emptyAttachedImage
                )
            }
            else {
                do {
                    let uploadUrls = try await self.worker.fetchImageUploadUrls(names: storedAttachedImages.map({ $0.name }))
                    try await self.worker.requestImagesUpload(attatchedImages: storedAttachedImages, imageUploadUrls: uploadUrls)
                    
                    response = UploadReceipt.UploadImage.Response(
                        uploadUrlObjectKeys: uploadUrls.map({ $0.objectKey }),
                        error: nil
                    )
                }
                catch {
                    response = UploadReceipt.UploadImage.Response(
                        uploadUrlObjectKeys: [],
                        error: .default(error)
                    )
                }
            }
            
            await self.store.execute(.mutateUploadImage(response: response))
            
        case .saveImage(let request):
            let response: UploadReceipt.SaveImage.Response
            
            do {
                try await self.worker.saveImage(imageUIData: request.imageUIData)
                response = UploadReceipt.SaveImage.Response(error: nil)
            }
            catch {
                response = UploadReceipt.SaveImage.Response(error: error)
            }
            
            await self.store.execute(.mutateSaveImage(response: response))
            
        case .showCamera(_):
            let response: UploadReceipt.ShowCamera.Response
            
            let cameraPermissionAccepted = await self.worker.requestCameraPermission()
            let galleryPermissionAccepted = await self.worker.requestGalleryPermission()
            let showingCameraPermissionAccepted = cameraPermissionAccepted && galleryPermissionAccepted
            response = UploadReceipt.ShowCamera.Response(permissionDenied: !showingCameraPermissionAccepted)
            
            await self.store.execute(.mutateShowCamera(response: response))
            
        case .showGallery(_):
            let response: UploadReceipt.ShowGallery.Response
            
            let galleryPermissionAccepted = await self.worker.requestGalleryPermission()
            let showingGalleryPermissionAccepted = galleryPermissionAccepted
            response =  UploadReceipt.ShowGallery.Response(permissionDenied: !showingGalleryPermissionAccepted)
            
            await self.store.execute(.mutateShowGallery(response: response))
        }
    }
}
