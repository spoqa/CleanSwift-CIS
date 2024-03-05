//
//  UploadReceiptInteractorTests.swift
//  Example
//
//  Created by 박건우 on 2024/01/23.
//  Copyright (c) 2023 Spoqa. All rights reserved.
//

import XCTest
import AddRequestsScene
@testable import UploadReceiptScene

class UploadReceiptInteractorTests: XCTestCase {
    
    var interactor: UploadReceiptInteractor!
    
    var mockStore: MockStore!
    var mockWorker: MockWorker!
    
    override func setUp() {
        super.setUp()
        
        self.mockStore = MockStore()
        self.mockWorker = MockWorker()
        self.interactor = UploadReceiptInteractor(store: self.mockStore, worker: self.mockWorker)
    }
    
    override func tearDown() {
        self.interactor = nil
        self.mockStore = nil
        self.mockWorker = nil
        super.tearDown()
    }
    
    // MARK: - Test Cases
    
    // MARK: - Test AttachImage UseCase
    
    func test_attachImage__첨부된이미지5개이상이면__exceedImageCount_에러() async {
        // Given
        let dummyRequest = UploadReceipt.AttachImage.Request(imageUIData: UploadReceipt.ImageUIDataModel())
        await MainActor.run {
            self.mockStore.domainState = UploadReceiptState.DomainState(attachedImages: [
                UploadReceipt.ImageModel(data: Data(), uiData: UploadReceipt.ImageUIDataModel()),
                UploadReceipt.ImageModel(data: Data(), uiData: UploadReceipt.ImageUIDataModel()),
                UploadReceipt.ImageModel(data: Data(), uiData: UploadReceipt.ImageUIDataModel()),
                UploadReceipt.ImageModel(data: Data(), uiData: UploadReceipt.ImageUIDataModel()),
                UploadReceipt.ImageModel(data: Data(), uiData: UploadReceipt.ImageUIDataModel())
            ])
        }
        
        // When
        await self.interactor.execute(.attachImage(request: dummyRequest))
        
        // Then
        XCTAssertEqual(self.mockStore.mutateAttachImageResponse?.error, .exceedImageCount)
    }
    
    func test_attachImage__첨부된이미지5개미만이면__worker_mapToData_호출() async {
        // Given
        let dummyRequest = UploadReceipt.AttachImage.Request(imageUIData: UploadReceipt.ImageUIDataModel())
        await MainActor.run {
            self.mockStore.domainState = UploadReceiptState.DomainState(attachedImages: [])
        }
        
        // When
        await self.interactor.execute(.attachImage(request: dummyRequest))
        
        // Then
        XCTAssertTrue(self.mockWorker.isMapToDataCalled)
    }
    
    func test_attachImage__첨부된이미지5개미만_그리고_worker_mapToData_nil이면__failDataMapping_에러() async {
        // Given
        let dummyRequest = UploadReceipt.AttachImage.Request(imageUIData: UploadReceipt.ImageUIDataModel())
        await MainActor.run {
            self.mockStore.domainState = UploadReceiptState.DomainState(attachedImages: [])
            self.mockWorker.mapToDataReturnValue = nil
        }
        
        // When
        await self.interactor.execute(.attachImage(request: dummyRequest))
        
        // Then
        XCTAssertEqual(self.mockStore.mutateAttachImageResponse?.error, .failDataMapping)
    }
    
    func test_attachImage__첨부된이미지5개미만_그리고_worker_mapToData_존재하면__attachedImages_추가() async {
        // Given
        let dummyUIData = UploadReceipt.ImageUIDataModel()
        let dummyRequest = UploadReceipt.AttachImage.Request(imageUIData: dummyUIData)
        let dummyData = Data()
        await MainActor.run {
            self.mockStore.domainState = UploadReceiptState.DomainState(attachedImages: [])
            self.mockWorker.mapToDataReturnValue = dummyData
        }
        
        // When
        await self.interactor.execute(.attachImage(request: dummyRequest))
        
        // Then
        XCTAssertEqual(self.mockStore.mutateAttachImageResponse?.attachedImages.count, 1)
        XCTAssertEqual(self.mockStore.mutateAttachImageResponse?.attachedImages.first?.data, dummyData)
        XCTAssertEqual(self.mockStore.mutateAttachImageResponse?.attachedImages.first?.uiData, dummyUIData)
    }
    
    // MARK: - Test UploadImage UseCase
    
    func test_uploadImage__첨부된이미지0개이면__emptyAttachedImage_에러() async {
        // Given
        let dummyRequest = UploadReceipt.UploadImage.Request()
        await MainActor.run {
            self.mockStore.domainState = UploadReceiptState.DomainState(attachedImages: [])
        }
        
        // When
        await self.interactor.execute(.uploadImage(request: dummyRequest))
        
        // Then
        if let error = self.mockStore.mutateUploadImageResponse?.error,
           case UploadReceipt.UploadImage.Response.Error.emptyAttachedImage = error {
            // pass
        }
        else {
            XCTFail()
        }
    }
    
    func test_uploadImage__첨부된이미지1개이상이면__worker_fetchImageUploadUrls_호출() async {
        // Given
        let dummyRequest = UploadReceipt.UploadImage.Request()
        await MainActor.run {
            self.mockStore.domainState = UploadReceiptState.DomainState(attachedImages: [
                UploadReceipt.ImageModel(data: Data(), uiData: UploadReceipt.ImageUIDataModel())
            ])
        }
        
        // When
        await self.interactor.execute(.uploadImage(request: dummyRequest))
        
        // Then
        XCTAssertTrue(self.mockWorker.isFetchImageUploadUrlsCalled)
    }
    
    func test_uploadImage__첨부된이미지1개이상_그리고_worker_fetchImageUploadUrls_성공이면__worker_requestImageUpload_호출() async {
        // Given
        let dummyRequest = UploadReceipt.UploadImage.Request()
        await MainActor.run {
            self.mockStore.domainState = UploadReceiptState.DomainState(attachedImages: [
                UploadReceipt.ImageModel(data: Data(), uiData: UploadReceipt.ImageUIDataModel())
            ])
            self.mockWorker.fetchImageUploadUrlsReturnValue = [
                UploadReceipt.ImageUploadUrl(uploadUrl: "test_uploadUrl", objectKey: "test_objectKey")
            ]
        }
        
        // When
        await self.interactor.execute(.uploadImage(request: dummyRequest))
        
        // Then
        XCTAssertTrue(self.mockWorker.isRequestImagesUploadCalled)
    }
    
    func test_uploadImage__첨부된이미지1개이상_그리고_worker_fetchImageUploadUrls_실패이면__default_에러() async {
        // Given
        let dummyRequest = UploadReceipt.UploadImage.Request()
        await MainActor.run {
            self.mockStore.domainState = UploadReceiptState.DomainState(attachedImages: [
                UploadReceipt.ImageModel(data: Data(), uiData: UploadReceipt.ImageUIDataModel())
            ])
            self.mockWorker.fetchImageUploadUrlsReturnValue = nil
        }
        
        // When
        await self.interactor.execute(.uploadImage(request: dummyRequest))
        
        // Then
        if let error = self.mockStore.mutateUploadImageResponse?.error,
           case UploadReceipt.UploadImage.Response.Error.default = error {
            // pass
        }
        else {
            XCTFail()
        }
    }
    
    func test_uploadImage__첨부된이미지1개이상_그리고_worker_fetchImageUploadUrls_성공_그리고_worker_requestImageUpload_성공이면__uploadUrlObjectKey_반환() async {
        // Given
        let dummyRequest = UploadReceipt.UploadImage.Request()
        let dummyUploadUrl = "test_uploadUrl"
        let dummyObjectKey = "test_objectKey"
        await MainActor.run {
            self.mockStore.domainState = UploadReceiptState.DomainState(attachedImages: [
                UploadReceipt.ImageModel(data: Data(), uiData: UploadReceipt.ImageUIDataModel())
            ])
            self.mockWorker.fetchImageUploadUrlsReturnValue = [
                UploadReceipt.ImageUploadUrl(uploadUrl: dummyUploadUrl, objectKey: dummyObjectKey)
            ]
            self.mockWorker.requestImagesUploadError = nil
        }
        
        // When
        await self.interactor.execute(.uploadImage(request: dummyRequest))
        
        // Then
        XCTAssertEqual(self.mockStore.mutateUploadImageResponse?.uploadUrlObjectKeys, [dummyObjectKey])
    }
    
    func test_uploadImage__첨부된이미지1개이상_그리고_worker_fetchImageUploadUrls_성공_그리고_worker_requestImageUpload_실패이면__default_에러() async {
        // Given
        let dummyRequest = UploadReceipt.UploadImage.Request()
        let dummyUploadUrl = "test_uploadUrl"
        let dummyObjectKey = "test_objectKey"
        await MainActor.run {
            self.mockStore.domainState = UploadReceiptState.DomainState(attachedImages: [
                UploadReceipt.ImageModel(data: Data(), uiData: UploadReceipt.ImageUIDataModel())
            ])
            self.mockWorker.fetchImageUploadUrlsReturnValue = [
                UploadReceipt.ImageUploadUrl(uploadUrl: dummyUploadUrl, objectKey: dummyObjectKey)
            ]
            self.mockWorker.requestImagesUploadError = NSError(domain: "Test_Error", code: -999, userInfo: nil)
        }
        
        // When
        await self.interactor.execute(.uploadImage(request: dummyRequest))
        
        // Then
        if let error = self.mockStore.mutateUploadImageResponse?.error,
           case UploadReceipt.UploadImage.Response.Error.default = error {
            // pass
        }
        else {
            XCTFail()
        }
    }
    
    // MARK: - Test SaveImage UseCase
    
    func test_saveImage__worker_saveImage_호출() async {
        // Given
        let dummyRequest = UploadReceipt.SaveImage.Request(imageUIData: UploadReceipt.ImageUIDataModel())
        
        // When
        await self.interactor.execute(.saveImage(request: dummyRequest))
        
        // Then
        XCTAssertTrue(self.mockWorker.isSaveImageCalled)
    }
    
    func test_saveImage__worker_saveImage_성공이면__error_nil_반환() async {
        // Given
        let dummyRequest = UploadReceipt.SaveImage.Request(imageUIData: UploadReceipt.ImageUIDataModel())
        await MainActor.run {
            self.mockWorker.saveImageError = nil
        }
        
        // When
        await self.interactor.execute(.saveImage(request: dummyRequest))
        
        // Then
        XCTAssertNil(self.mockStore.mutateSaveImageResponse?.error)
    }
    
    func test_saveImage__worker_saveImage_성공이면__error_반환() async {
        // Given
        let dummyRequest = UploadReceipt.SaveImage.Request(imageUIData: UploadReceipt.ImageUIDataModel())
        await MainActor.run {
            self.mockWorker.saveImageError = NSError(domain: "Test_Error", code: -999, userInfo: nil)
        }
        
        // When
        await self.interactor.execute(.saveImage(request: dummyRequest))
        
        // Then
        XCTAssertNotNil(self.mockStore.mutateSaveImageResponse?.error)
    }
    
    // MARK: - Test ShowCamera UseCase
    
    func test_showCamera__worker_requestCameraPermission_호출() async {
        // Given
        let dummyRequest = UploadReceipt.ShowCamera.Request()
        
        // When
        await self.interactor.execute(.showCamera(request: dummyRequest))
        
        // Then
        XCTAssertTrue(self.mockWorker.isRequestCameraPermissionCalled)
    }
    
    func test_showCamera__worker_requestGalleryPermission_호출() async {
        // Given
        let dummyRequest = UploadReceipt.ShowCamera.Request()
        
        // When
        await self.interactor.execute(.showCamera(request: dummyRequest))
        
        // Then
        XCTAssertTrue(self.mockWorker.isRequestGalleryPermissionCalled)
    }
    
    func test_showCamera__worker_requestCameraPermission_false이면__permissionDenied_true_반환() async {
        // Given
        let dummyRequest = UploadReceipt.ShowCamera.Request()
        await MainActor.run {
            self.mockWorker.requestCameraPermissionReturnValue = false
        }
        
        // When
        await self.interactor.execute(.showCamera(request: dummyRequest))
        
        // Then
        XCTAssertEqual(self.mockStore.mutateShowCameraResponse?.permissionDenied, true)
    }
    
    func test_showCamera__worker_requestGalleryPermission_false이면__permissionDenied_true_반환() async {
        // Given
        let dummyRequest = UploadReceipt.ShowCamera.Request()
        await MainActor.run {
            self.mockWorker.requestGalleryPermissionReturnValue = false
        }
        
        // When
        await self.interactor.execute(.showCamera(request: dummyRequest))
        
        // Then
        XCTAssertEqual(self.mockStore.mutateShowCameraResponse?.permissionDenied, true)
    }
    
    func test_showCamera__worker_requestCameraPermission_true_그리고_worker_requestGalleryPermission_true이면__permissionDenied_false_반환() async {
        // Given
        let dummyRequest = UploadReceipt.ShowCamera.Request()
        await MainActor.run {
            self.mockWorker.requestCameraPermissionReturnValue = true
            self.mockWorker.requestGalleryPermissionReturnValue = true
        }
        
        // When
        await self.interactor.execute(.showCamera(request: dummyRequest))
        
        // Then
        XCTAssertEqual(self.mockStore.mutateShowCameraResponse?.permissionDenied, false)
    }
    
    // MARK: - Test ShowGallery UseCase
    
    func test_showGallery__worker_requestGalleryPermission_호출() async {
        // Given
        let dummyRequest = UploadReceipt.ShowGallery.Request()
        
        // When
        await self.interactor.execute(.showGallery(request: dummyRequest))
        
        // Then
        XCTAssertTrue(self.mockWorker.isRequestGalleryPermissionCalled)
    }
    
    func test_showGallery__worker_requestGalleryPermission_false이면__permissionDenied_true_반환() async {
        // Given
        let dummyRequest = UploadReceipt.ShowGallery.Request()
        await MainActor.run {
            self.mockWorker.requestGalleryPermissionReturnValue = false
        }
        
        // When
        await self.interactor.execute(.showGallery(request: dummyRequest))
        
        // Then
        XCTAssertEqual(self.mockStore.mutateShowGalleryResponse?.permissionDenied, true)
    }
    
    func test_showGallery__worker_requestGalleryPermission_true이면__permissionDenied_false_반환() async {
        // Given
        let dummyRequest = UploadReceipt.ShowGallery.Request()
        await MainActor.run {
            self.mockWorker.requestGalleryPermissionReturnValue = true
        }
        
        // When
        await self.interactor.execute(.showGallery(request: dummyRequest))
        
        // Then
        XCTAssertEqual(self.mockStore.mutateShowGalleryResponse?.permissionDenied, false)
    }
}

// MARK: - Mock Classes

extension UploadReceiptInteractorTests {

    class MockStore: UploadReceiptMutatable, HasUploadReceiptDomainState {
        @MainActor var domainState = UploadReceiptState.DomainState()
        
        var mutateAttachImageResponse: UploadReceipt.AttachImage.Response?
        var mutateUploadImageResponse: UploadReceipt.UploadImage.Response?
        var mutateSaveImageResponse: UploadReceipt.SaveImage.Response?
        var mutateShowCameraResponse: UploadReceipt.ShowCamera.Response?
        var mutateShowGalleryResponse: UploadReceipt.ShowGallery.Response?

        @MainActor func execute(_ mutation: UploadReceiptMutation) {
            switch mutation {
            case .mutateAttachImage(let response):
                self.mutateAttachImageResponse = response
                
            case .mutateUploadImage(let response):
                self.mutateUploadImageResponse = response
                
            case .mutateSaveImage(let response):
                self.mutateSaveImageResponse = response
                
            case .mutateShowCamera(let response):
                self.mutateShowCameraResponse = response
                
            case .mutateShowGallery(let response):
                self.mutateShowGalleryResponse = response
                
            default:
                break
            }
        }
    }

    class MockWorker: UploadReceiptWorkable {
        var delegate: UploadReceiptDelegate?
        var addRequestsController: AddRequestsControllerable?
        
        var isMapToDataCalled = false
        var mapToDataReturnValue: Data?
        var isFetchImageUploadUrlsCalled = false
        var fetchImageUploadUrlsReturnValue: [UploadReceipt.ImageUploadUrl]?
        var isRequestImagesUploadCalled = false
        var requestImagesUploadError: Error?
        var isRequestCameraPermissionCalled = false
        var requestCameraPermissionReturnValue: Bool = false
        var isRequestGalleryPermissionCalled = false
        var requestGalleryPermissionReturnValue: Bool = false
        var isSaveImageCalled = false
        var saveImageError: Error?

        @MainActor func showToast(message: String) {}

        func mapToData(from imageUIData: UploadReceipt.ImageUIDataModel) -> Data? {
            self.isMapToDataCalled = true
            return self.mapToDataReturnValue
        }

        func fetchImageUploadUrls(names: [String]) async throws -> [UploadReceipt.ImageUploadUrl] {
            self.isFetchImageUploadUrlsCalled = true
            if let returnValue = self.fetchImageUploadUrlsReturnValue {
                return returnValue
            } else {
                throw NSError(domain: "Test_Error", code: -999, userInfo: nil)
            }
        }

        func requestImagesUpload(attatchedImages: [UploadReceipt.ImageModel], imageUploadUrls: [UploadReceipt.ImageUploadUrl]) async throws {
            self.isRequestImagesUploadCalled = true
            if let error = self.requestImagesUploadError {
                throw error
            }
        }

        func requestCameraPermission() async -> Bool {
            self.isRequestCameraPermissionCalled = true
            return self.requestCameraPermissionReturnValue
        }

        func requestGalleryPermission() async -> Bool {
            self.isRequestGalleryPermissionCalled = true
            return self.requestGalleryPermissionReturnValue
        }

        func saveImage(imageUIData: UploadReceipt.ImageUIDataModel) async throws {
            self.isSaveImageCalled = true
            if let error = self.saveImageError {
                throw error
            }
        }
    }
}
