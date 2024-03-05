//
//  UploadReceiptStoreTests.swift
//  Example
//
//  Created by 박건우 on 2024/01/23.
//  Copyright (c) 2023 Spoqa. All rights reserved.
//

import XCTest
import AddRequestsScene
@testable import UploadReceiptScene

@MainActor class UploadReceiptStoreTests: XCTestCase {
    
    var store: UploadReceiptStore!
    @MainActor var state: UploadReceiptState { self.store.state }
    
    var mockWorker: MockWorker!
    
    override func setUp() {
        super.setUp()
        
        self.mockWorker = MockWorker()
        self.configure(initialState: UploadReceiptState())
    }
    
    private func configure(initialState: UploadReceiptState) {
        self.store = UploadReceiptStore(worker: self.mockWorker, state: initialState)
    }
    
    override func tearDown() {
        self.store = nil
        self.mockWorker = nil
        super.tearDown()
    }
    
    // MARK: - Test Cases
    
    func test_mutateAttachImage__error_exceedImageCount() {
        // Given
        let dummyResponse = UploadReceipt.AttachImage.Response(attachedImages: [], error: .exceedImageCount)
        
        // When
        self.store.execute(.mutateAttachImage(response: dummyResponse))
        
        // Then
        XCTAssertEqual(self.mockWorker.showToastMessage, "최대 5장까지 첨부할 수 있습니다")
    }
    
    func test_mutateAttachImage__error_failDataMapping() {
        // Given
        let dummyResponse = UploadReceipt.AttachImage.Response(attachedImages: [], error: .failDataMapping)
        
        // When
        self.store.execute(.mutateAttachImage(response: dummyResponse))
        
        // Then
        XCTAssertEqual(self.mockWorker.showToastMessage, "사진 처리 과정에서 오류가 발생하였습니다")
    }
    
    func test_mutateAttachImage__success() {
        // Given
        let dummyAttachedImages = [UploadReceipt.ImageModel(data: Data(), uiData: UploadReceipt.ImageUIDataModel())]
        let dummyResponse = UploadReceipt.AttachImage.Response(attachedImages: dummyAttachedImages, error: nil)
        
        // When
        self.store.execute(.mutateAttachImage(response: dummyResponse))
        
        // Then
        XCTAssertEqual(self.state.domainState.attachedImages, dummyAttachedImages)
        XCTAssertEqual(self.state.attachedImages, dummyAttachedImages.map({ $0.uiData }))
    }
    
    func test_mutateUploadImage__error_emptyAttachedImage() {
        // Given
        let dummyResponse = UploadReceipt.UploadImage.Response(uploadUrlObjectKeys: [], error: .emptyAttachedImage)
        
        // When
        self.store.execute(.mutateUploadImage(response: dummyResponse))
        
        // Then
        XCTAssertEqual(self.mockWorker.showToastMessage, "견적 요청을 하기 위해서\n필수로 이미지를 첨부하여야 합니다")
    }
    
    func test_mutateUploadImage__error_default() {
        // Given
        let dummyResponse = UploadReceipt.UploadImage.Response(uploadUrlObjectKeys: [], error: .default(NSError(domain: "Test_Error", code: -999, userInfo: nil)))
        
        // When
        self.store.execute(.mutateUploadImage(response: dummyResponse))
        
        // Then
        XCTAssertEqual(self.mockWorker.showToastMessage, "작업을 완료할 수 없습니다.(Test_Error 오류 -999.)")
    }
    
    func test_mutateUploadImage__success() async {
        // Given
        let dummyUploadUrlObjectKeys = ["test_uploadUrlObjectKey"]
        let dummyResponse = UploadReceipt.UploadImage.Response(uploadUrlObjectKeys: dummyUploadUrlObjectKeys, error: nil)
        
        // When
        self.store.execute(.mutateUploadImage(response: dummyResponse))
        
        // Then
        XCTAssertEqual(self.state.receiptImageUploadUrlObjectKeys, dummyUploadUrlObjectKeys)
        XCTAssertTrue(self.state.isAddRequestsViewActive)
    }
    
    func test_mutateSaveImage__error() async {
        // Given
        let dummyResponse = UploadReceipt.SaveImage.Response(error: NSError(domain: "Test_Error", code: -999, userInfo: nil))
        
        // When
        self.store.execute(.mutateSaveImage(response: dummyResponse))
        
        // Then
        XCTAssertEqual(self.mockWorker.showToastMessage, "작업을 완료할 수 없습니다.(Test_Error 오류 -999.)")
    }
    
    func test_mutateSaveImage__success() async {
        // Given
        let dummyResponse = UploadReceipt.SaveImage.Response(error: nil)
        
        // When
        self.store.execute(.mutateSaveImage(response: dummyResponse))
        
        // Then
        XCTAssertNil(self.mockWorker.showToastMessage)
    }
    
    func test_mutateShowCamera__permissionDenied_true() async {
        // Given
        let dummyResponse = UploadReceipt.ShowCamera.Response(permissionDenied: true)
        
        // When
        self.store.execute(.mutateShowCamera(response: dummyResponse))
        
        // Then
        XCTAssertEqual(self.mockWorker.showToastMessage, "명세표를 업로드하기 위해서\n카메라 및 모든 사진 접근 권한이 필요합니다")
        XCTAssertFalse(self.state.showingCamera)
    }
    
    func test_mutateShowCamera__permissionDenied_false() async {
        // Given
        let dummyResponse = UploadReceipt.ShowCamera.Response(permissionDenied: false)
        
        // When
        self.store.execute(.mutateShowCamera(response: dummyResponse))
        
        // Then
        XCTAssertNil(self.mockWorker.showToastMessage)
        XCTAssertTrue(self.state.showingCamera)
    }
    
    func test_mutateShowGallery__permissionDenied_true() async {
        // Given
        let dummyResponse = UploadReceipt.ShowGallery.Response(permissionDenied: true)
        
        // When
        self.store.execute(.mutateShowGallery(response: dummyResponse))
        
        // Then
        XCTAssertEqual(self.mockWorker.showToastMessage, "명세표를 업로드하기 위해서\n 모든 사진 접근 권한이 필요합니다")
        XCTAssertFalse(self.state.showingImagePicker)
    }
    
    func test_mutateShowGallery__permissionDenied_false() async {
        // Given
        let dummyResponse = UploadReceipt.ShowGallery.Response(permissionDenied: false)
        
        // When
        self.store.execute(.mutateShowGallery(response: dummyResponse))
        
        // Then
        XCTAssertNil(self.mockWorker.showToastMessage)
        XCTAssertTrue(self.state.showingImagePicker)
    }
    
    func test_showSelectImageAttachmentMethodSheet() async {
        // Given
        
        // When
        self.store.execute(.showSelectImageAttachmentMethodSheet)
        
        // Then
        XCTAssertTrue(self.state.showingSelectImageAttachmentMethodSheet)
    }
    
    func test_dismissSelectImageAttachmentMethodSheet() async {
        // Given
        
        // When
        self.store.execute(.dismissSelectImageAttachmentMethodSheet)
        
        // Then
        XCTAssertFalse(self.state.showingSelectImageAttachmentMethodSheet)
    }
    
    func test_dismissCamera() async {
        // Given
        
        // When
        self.store.execute(.dismissCamera)
        
        // Then
        XCTAssertFalse(self.state.showingCamera)
    }
    
    func test_dismissImagePicker() async {
        // Given
        
        // When
        self.store.execute(.dismissImagePicker)
        
        // Then
        XCTAssertFalse(self.state.showingImagePicker)
    }
    
    func test_showMessage() async {
        // Given
        let dummyMessage = "Test"
        
        // When
        self.store.execute(.showMessage(message: dummyMessage))
        
        // Then
        XCTAssertEqual(self.mockWorker.showToastMessage, dummyMessage)
    }
    
    func test_clearAttachedImages() async {
        // Given
        
        // When
        self.store.execute(.clearAttachedImages)
        
        // Then
        XCTAssertEqual(self.state.attachedImages, [])
        XCTAssertEqual(self.state.domainState.attachedImages, [])
    }
    
    func test_setIsActiveAddRequestsView() async {
        // Given
        let dummyIsActive = true
        
        // When
        self.store.execute(.setIsActiveAddRequestsView(isActive: dummyIsActive))
        
        // Then
        XCTAssertEqual(self.state.isAddRequestsViewActive, dummyIsActive)
    }
}

// MARK: - Mock Classes

extension UploadReceiptStoreTests {
    
    class MockWorker: UploadReceiptWorkable {
        var delegate: UploadReceiptDelegate?
        var addRequestsController: AddRequestsControllerable?
        
        var showToastMessage: String?

        @MainActor func showToast(message: String) {
            self.showToastMessage = message
        }

        func mapToData(from imageUIData: UploadReceipt.ImageUIDataModel) -> Data? {
            return nil
        }

        func fetchImageUploadUrls(names: [String]) async throws -> [UploadReceipt.ImageUploadUrl] {
            return []
        }

        func requestImagesUpload(attatchedImages: [UploadReceipt.ImageModel], imageUploadUrls: [UploadReceipt.ImageUploadUrl]) async throws {
            return
        }

        func requestCameraPermission() async -> Bool {
            return false
        }

        func requestGalleryPermission() async -> Bool {
            return false
        }

        func saveImage(imageUIData: UploadReceipt.ImageUIDataModel) async throws {
            return
        }
    }
}
