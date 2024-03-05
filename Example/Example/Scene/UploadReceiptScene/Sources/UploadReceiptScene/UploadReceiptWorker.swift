//
//  UploadReceiptWorker.swift
//  Example
//
//  Created by 박건우 on 2023/12/21.
//  Copyright (c) 2023 Spoqa. All rights reserved.
//

import AddRequestsScene
import NetworkService

import Toaster
import Photos

// MARK: - Delegate

public protocol UploadReceiptDelegate: AnyObject {
}

// MARK: - Worker

protocol UploadReceiptWorkable: AnyObject {
    var delegate: UploadReceiptDelegate? { get set }
    var addRequestsController: AddRequestsControllerable? { get set }
    
    @MainActor func showToast(message: String)
    
    func mapToData(from imageUIData: UploadReceipt.ImageUIDataModel) -> Data?
    func fetchImageUploadUrls(names: [String]) async throws -> [UploadReceipt.ImageUploadUrl]
    func requestImagesUpload(attatchedImages: [UploadReceipt.ImageModel], imageUploadUrls: [UploadReceipt.ImageUploadUrl]) async throws
    func requestCameraPermission() async -> Bool
    func requestGalleryPermission() async -> Bool
    func saveImage(imageUIData: UploadReceipt.ImageUIDataModel) async throws
}

final class UploadReceiptWorker: UploadReceiptWorkable {
    
    weak var delegate: UploadReceiptDelegate?
    weak var addRequestsController: AddRequestsControllerable?
    
    private let imageUploadNetworkService: ImageUploadNetworkServiceProtocol
    
    init(
        delegate: UploadReceiptDelegate,
        imageUploadNetworkService: ImageUploadNetworkServiceProtocol
    ) {
        self.delegate = delegate
        self.imageUploadNetworkService = imageUploadNetworkService
    }
}

// MARK: - Implement

extension UploadReceiptWorker {
    
    func mapToData(from imageUIData: UploadReceipt.ImageUIDataModel) -> Data? {
        return imageUIData.jpegData(compressionQuality: 1.0)
    }
    
    func fetchImageUploadUrls(names: [String]) async throws -> [UploadReceipt.ImageUploadUrl] {
        let dto = try await self.imageUploadNetworkService.queryImageUploadUrls(fileNames: names.map({ $0.appending(".jpg")}))
        return dto.uploadUrls.map({
            UploadReceipt.ImageUploadUrl(uploadUrl: $0.uploadUrl, objectKey: $0.objectKey)
        })
    }
    
    func requestImagesUpload(attatchedImages: [UploadReceipt.ImageModel], imageUploadUrls: [UploadReceipt.ImageUploadUrl]) async throws {
        return try await withThrowingTaskGroup(of: Void.self) { group in
            for (imageUploadUrl, attachedImage) in zip(imageUploadUrls, attatchedImages) {
                group.addTask {
                    try await self.imageUploadNetworkService.putImageData(to: imageUploadUrl.uploadUrl, imageData: attachedImage.data)
                }
            }
            try await group.waitForAll()
        }
    }
    
    func requestCameraPermission() async -> Bool {
        return await withCheckedContinuation { continuation in
            AVCaptureDevice.requestAccess(for: .video) { granted in
                continuation.resume(returning: granted)
            }
        }
    }
    
    func requestGalleryPermission() async -> Bool {
        return await withCheckedContinuation { continuation in
            if #available(iOS 14, *) {
                PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                    continuation.resume(returning: status == .authorized)
                }
            } else {
                PHPhotoLibrary.requestAuthorization { status in
                    continuation.resume(returning: status == .authorized)
                }
            }
        }
    }
    
    func saveImage(imageUIData: UploadReceipt.ImageUIDataModel) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAsset(from: imageUIData)
            }) { success, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                continuation.resume()
            }
        }
    }
    
    @MainActor func showToast(message: String) {
        Toast(text: message).show()
    }
}
