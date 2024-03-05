//
//  UploadReceiptControllerTests.swift
//  Example
//
//  Created by 박건우 on 2024/01/23.
//  Copyright (c) 2023 Spoqa. All rights reserved.
//

import XCTest
@testable import UploadReceiptScene

class UploadReceiptControllerTests: XCTestCase {
    
    var controller: UploadReceiptController!
    
    var mockInteractor: MockInteractor!
    var mockStore: MockStore!
    
    override func setUp() {
        super.setUp()
        
        self.mockInteractor = MockInteractor()
        self.mockStore = MockStore()
        self.controller = UploadReceiptController(interactor: self.mockInteractor, store: self.mockStore)
    }
    
    override func tearDown() {
        self.controller = nil
        self.mockInteractor = nil
        self.mockStore = nil
        super.tearDown()
    }
    
    // MARK: - Test Cases
    
    func test_imageAttachTapped() async {
        // Given
        
        // When
        await self.controller.execute(.imageAttachTapped).value
        
        // Then
        XCTAssertTrue(self.mockStore.isShowSelectImageAttachmentMethodSheetCalled)
    }
    
    func test_imageAttachmentMethodCameraSelected() async {
        // Given
        
        // When
        await self.controller.execute(.imageAttachmentMethodCameraSelected).value
        
        // Then
        XCTAssertTrue(self.mockStore.isDismissSelectImageAttachmentMethodSheetCalled)
        XCTAssertTrue(self.mockInteractor.isShowCameraCalled)
    }
    
    func test_imageAttachmentMethodGallerySelected() async {
        // Given
        
        // When
        await self.controller.execute(.imageAttachmentMethodGallerySelected).value
        
        // Then
        XCTAssertTrue(self.mockStore.isDismissSelectImageAttachmentMethodSheetCalled)
        XCTAssertTrue(self.mockInteractor.isShowGalleryCalled)
    }
    
    func test_cameraCanceled() async {
        // Given
        
        // When
        await self.controller.execute(.cameraCanceled).value
        
        // Then
        XCTAssertTrue(self.mockStore.isDismissCameraCalled)
    }
    
    func test_cameraPhotoTakenCompleted() async {
        // Given
        let dummyImage = UploadReceipt.ImageUIDataModel()
        
        // When
        await self.controller.execute(.cameraPhotoTakenCompleted(image: dummyImage)).value
        
        // Then
        XCTAssertTrue(self.mockInteractor.isSaveImageCalled)
        XCTAssertTrue(self.mockInteractor.isAttachImageCalled)
        XCTAssertTrue(self.mockStore.isDismissCameraCalled)
    }
    
    func test_imagePickerCanceled() async {
        // Given
        
        // When
        await self.controller.execute(.imagePickerCanceled).value
        
        // Then
        XCTAssertTrue(self.mockStore.isDismissImagePickerCalled)
    }
    
    func test_imagePicked() async {
        // Given
        let dummyImage = UploadReceipt.ImageUIDataModel()
        
        // When
        await self.controller.execute(.imagePicked(image: dummyImage)).value
        
        // Then
        XCTAssertTrue(self.mockInteractor.isAttachImageCalled)
        XCTAssertTrue(self.mockStore.isDismissImagePickerCalled)
    }
    
    func test_nextButtonTapped() async {
        // Given
        
        // When
        await self.controller.execute(.nextButtonTapped).value
        
        // Then
        XCTAssertTrue(self.mockInteractor.isUploadImageCalled)
    }
    
    func test_addRequestsViewIsActiveChanged() async {
        // Given
        
        // When
        await self.controller.execute(.addRequestsViewIsActiveChanged(isActive: true)).value
        
        // Then
        XCTAssertTrue(self.mockStore.isSetActiveAddRequestsViewCalled)
    }
    
}

// MARK: - Mock Classes

extension UploadReceiptControllerTests {

    class MockInteractor: UploadReceiptInteractable {
        var isShowCameraCalled = false
        var isShowGalleryCalled = false
        var isSaveImageCalled = false
        var isAttachImageCalled = false
        var isUploadImageCalled = false
        
        func execute(_ useCase: UploadReceiptUseCase) async {
            switch useCase {
            case .showCamera:
                self.isShowCameraCalled = true
                
            case .showGallery:
                self.isShowGalleryCalled = true
                
            case .saveImage:
                self.isSaveImageCalled = true
                
            case .attachImage:
                self.isAttachImageCalled = true
                
            case .uploadImage:
                self.isUploadImageCalled = true
            }
        }
    }

    class MockStore: UploadReceiptMutatable {
        var isShowSelectImageAttachmentMethodSheetCalled = false
        var isDismissSelectImageAttachmentMethodSheetCalled = false
        var isDismissCameraCalled = false
        var isDismissImagePickerCalled = false
        var isSetActiveAddRequestsViewCalled = false

        @MainActor func execute(_ mutation: UploadReceiptMutation) {
            switch mutation {
            case .showSelectImageAttachmentMethodSheet:
                self.isShowSelectImageAttachmentMethodSheetCalled = true
                
            case .dismissSelectImageAttachmentMethodSheet:
                self.isDismissSelectImageAttachmentMethodSheetCalled = true
                
            case .dismissCamera:
                self.isDismissCameraCalled = true
                
            case .dismissImagePicker:
                self.isDismissImagePickerCalled = true
                
            case .setIsActiveAddRequestsView:
                self.isSetActiveAddRequestsViewCalled = true
                
            default:
                break
            }
        }
    }
}
