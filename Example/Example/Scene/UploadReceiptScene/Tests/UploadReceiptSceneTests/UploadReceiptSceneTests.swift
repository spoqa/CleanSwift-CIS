//
//  UploadReceiptSceneTests.swift
//  Example
//
//  Created by 박건우 on 2023/12/21.
//  Copyright (c) 2023 Spoqa. All rights reserved.
//

import XCTest
import AddRequestsScene
@testable import UploadReceiptScene

class UploadReceiptSceneTests: XCTestCase {
    
    var controller: UploadReceiptController!
    @MainActor var state: UploadReceiptState { self.store.state }
    
    var store: UploadReceiptStore!
    var interactor: UploadReceiptInteractor!
    
    var mockWorker: MockWorker!
    
    @MainActor override func setUp() {
        super.setUp()
        
        self.mockWorker = MockWorker()
        self.configure(initialState: UploadReceiptState())
    }
    
    @MainActor private func configure(initialState: UploadReceiptState) {
        self.store = UploadReceiptStore(worker: self.mockWorker, state: initialState)
        self.interactor = UploadReceiptInteractor(store: self.store, worker: self.mockWorker)
        self.controller = UploadReceiptController(interactor: self.interactor, store: self.store)
    }
    
    override func tearDown() {
        self.controller = nil
        self.store = nil
        self.interactor = nil
        self.mockWorker = nil
        super.tearDown()
    }
    
    // MARK: - Test Scenarios
    
    func test_사진첨부버튼클릭__사진첨부수단시트표출됨() async {
        // Given
        
        // When
        await self.controller.execute(.imageAttachTapped).value
        
        // Then
        let showingSelectImageAttachmentMethodSheet = await self.state.showingSelectImageAttachmentMethodSheet
        
        XCTAssertEqual(showingSelectImageAttachmentMethodSheet, true)
    }

    func test_사진촬영하기옵션클릭__사진첨부수단시트표출되지않음() async {
        // Given
        await MainActor.run {
            self.mockWorker.requestCameraPermissionResult = true
            self.mockWorker.requestGalleryPermissionResult = true
        }
        
        // When
        await self.controller.execute(.imageAttachmentMethodCameraSelected).value
        
        // Then
        let showingSelectImageAttachmentMethodSheet = await self.state.showingSelectImageAttachmentMethodSheet
        
        XCTAssertEqual(showingSelectImageAttachmentMethodSheet, false)
    }

    func test_사진촬영하기옵션클릭_카메라접근권한거부__토스트메세지표출됨() async {
        // Given
        await MainActor.run {
            self.mockWorker.requestCameraPermissionResult = false
            self.mockWorker.requestGalleryPermissionResult = true
        }
        
        // When
        await self.controller.execute(.imageAttachmentMethodCameraSelected).value
        
        // Then
        let lastShowToastMessage = self.mockWorker.lastShowToastMessage
        
        XCTAssertEqual(lastShowToastMessage, "명세표를 업로드하기 위해서\n카메라 및 모든 사진 접근 권한이 필요합니다")
    }

    func test_사진촬영하기옵션클릭_사진접근권한거부__토스트메세지표출됨() async {
        // Given
        await MainActor.run {
            self.mockWorker.requestCameraPermissionResult = true
            self.mockWorker.requestGalleryPermissionResult = false
        }
        
        // When
        await self.controller.execute(.imageAttachmentMethodCameraSelected).value
        
        // Then
        let lastShowToastMessage = self.mockWorker.lastShowToastMessage
        
        XCTAssertEqual(lastShowToastMessage, "명세표를 업로드하기 위해서\n카메라 및 모든 사진 접근 권한이 필요합니다")
    }

    func test_사진촬영하기옵션클릭_카메라사진접근권한허용__카메라표출됨() async {
        // Given
        await MainActor.run {
            self.mockWorker.requestCameraPermissionResult = true
            self.mockWorker.requestGalleryPermissionResult = true
        }
        
        // When
        await self.controller.execute(.imageAttachmentMethodCameraSelected).value
        
        // Then
        let showingCamera = await self.state.showingCamera
        
        XCTAssertEqual(showingCamera, true)
    }

    func test_사진첩에서가져오기옵션클릭__사진첨부수단시트표출되지않음() async {
        // Given
        await MainActor.run {
            self.mockWorker.requestGalleryPermissionResult = false
        }
        
        // When
        await self.controller.execute(.imageAttachmentMethodGallerySelected).value
        
        // Then
        let showingSelectImageAttachmentMethodSheet = await self.state.showingSelectImageAttachmentMethodSheet
        
        XCTAssertEqual(showingSelectImageAttachmentMethodSheet, false)
    }

    func test_사진첩에서가져오기옵션클릭_사진접근권한거부__토스트메세지표출됨() async {
        // Given
        await MainActor.run {
            self.mockWorker.requestGalleryPermissionResult = false
        }
        
        // When
        await self.controller.execute(.imageAttachmentMethodGallerySelected).value
        
        // Then
        let lastShowToastMessage = self.mockWorker.lastShowToastMessage
        
        XCTAssertEqual(lastShowToastMessage, "명세표를 업로드하기 위해서\n 모든 사진 접근 권한이 필요합니다")
    }

    func test_사진첩에서가져오기옵션클릭_사진접근권한허용__이미지피커표출됨() async {
        // Given
        await MainActor.run {
            self.mockWorker.requestGalleryPermissionResult = true
        }
        
        // When
        await self.controller.execute(.imageAttachmentMethodGallerySelected).value
        
        // Then
        let showingImagePicker = await self.state.showingImagePicker
        
        XCTAssertEqual(showingImagePicker, true)
    }

    func test_카메라촬영취소__카메라표출되지않음() async {
        // Given
        
        // When
        await self.controller.execute(.cameraCanceled).value
        
        // Then
        let showingCamera = await self.state.showingCamera
        
        XCTAssertEqual(showingCamera, false)
    }

    func test_카메라촬영완료__카메라표출되지않음() async {
        // Given
        await MainActor.run {
            self.mockWorker.saveImageResult = .failure(NSError(domain: "Test", code: -999))
        }
        
        // When
        await self.controller.execute(.cameraPhotoTakenCompleted(image: UploadReceipt.ImageUIDataModel())).value
        
        // Then
        let showingCamera = await self.state.showingCamera
        
        XCTAssertEqual(showingCamera, false)
    }

    func test_카메라촬영완료_사진저장실패__토스트메세지표출됨() async {
        // Given
        await MainActor.run {
            self.mockWorker.saveImageResult = .failure(NSError(domain: "Test", code: -999))
            self.mockWorker.mapToDataResult = Data()
        }
        
        // When
        await self.controller.execute(.cameraPhotoTakenCompleted(image: UploadReceipt.ImageUIDataModel())).value
        
        // Then
        let lastShowToastMessage = self.mockWorker.lastShowToastMessage
        
        XCTAssertEqual(lastShowToastMessage, "작업을 완료할 수 없습니다.(Test 오류 -999.)")
    }

    func test_카메라촬영완료_사진데이터매핑실패__토스트메세지표출됨() async {
        // Given
        await MainActor.run {
            self.mockWorker.saveImageResult = .success(())
            self.mockWorker.mapToDataResult = nil
        }
        
        // When
        await self.controller.execute(.cameraPhotoTakenCompleted(image: UploadReceipt.ImageUIDataModel())).value
        
        // Then
        let lastShowToastMessage = self.mockWorker.lastShowToastMessage
        
        XCTAssertEqual(lastShowToastMessage, "사진 처리 과정에서 오류가 발생하였습니다")
    }

    func test_카메라촬영완료_첨부된사진5개이상__토스트메세지표출됨() async {
        // Given
        await MainActor.run {
            self.mockWorker.saveImageResult = .success(())
            self.mockWorker.mapToDataResult = Data()
            
            var state = UploadReceiptState()
            state.domainState.attachedImages = [
                UploadReceipt.ImageModel(data: Data(), uiData: UIImage()),
                UploadReceipt.ImageModel(data: Data(), uiData: UIImage()),
                UploadReceipt.ImageModel(data: Data(), uiData: UIImage()),
                UploadReceipt.ImageModel(data: Data(), uiData: UIImage()),
                UploadReceipt.ImageModel(data: Data(), uiData: UIImage())
            ]
            self.configure(initialState: state)
        }
        
        // When
        await self.controller.execute(.cameraPhotoTakenCompleted(image: UploadReceipt.ImageUIDataModel())).value
        
        // Then
        let lastShowToastMessage = self.mockWorker.lastShowToastMessage
        
        XCTAssertEqual(lastShowToastMessage, "최대 5장까지 첨부할 수 있습니다")
    }

    func test_카메라촬영완료_첨부된사진5개미만__첨부된이미지목록에추가됨() async {
        // Given
        await MainActor.run {
            self.mockWorker.saveImageResult = .success(())
            self.mockWorker.mapToDataResult = Data()
            
            var state = UploadReceiptState()
            state.domainState.attachedImages = [
                UploadReceipt.ImageModel(data: Data(), uiData: UIImage()),
                UploadReceipt.ImageModel(data: Data(), uiData: UIImage()),
                UploadReceipt.ImageModel(data: Data(), uiData: UIImage()),
                UploadReceipt.ImageModel(data: Data(), uiData: UIImage())
            ]
            self.configure(initialState: state)
        }
        
        // When
        await self.controller.execute(.cameraPhotoTakenCompleted(image: UploadReceipt.ImageUIDataModel())).value
        
        // Then
        let domainAttachedImages = await self.state.domainState.attachedImages
        let attachedImages = await self.state.attachedImages
        
        XCTAssertEqual(domainAttachedImages.count, 5)
        XCTAssertEqual(attachedImages.count, 5)
    }

    func test_사진선택취소__이미지피커표출되지않음() async {
        // Given
        
        // When
        await self.controller.execute(.imagePickerCanceled).value
        
        // Then
        let showingImagePicker = await self.state.showingImagePicker
        
        XCTAssertEqual(showingImagePicker, false)
    }

    func test_사진선택완료__이미지피커표출되지않음() async {
        // Given
        
        // When
        await self.controller.execute(.imagePicked(image: UploadReceipt.ImageUIDataModel())).value
        
        // Then
        let showingImagePicker = await self.state.showingImagePicker
        
        XCTAssertEqual(showingImagePicker, false)
    }

    func test_사진선택완료_사진데이터매핑실패__토스트메세지표출됨() async {
        // Given
        await MainActor.run {
            self.mockWorker.mapToDataResult = nil
        }
        
        // When
        await self.controller.execute(.imagePicked(image: UploadReceipt.ImageUIDataModel())).value
        
        // Then
        let lastShowToastMessage = self.mockWorker.lastShowToastMessage
        
        XCTAssertEqual(lastShowToastMessage, "사진 처리 과정에서 오류가 발생하였습니다")
    }

    func test_사진선택완료_첨부된사진5개이상__토스트메세지표출됨() async {
        // Given
        await MainActor.run {
            self.mockWorker.mapToDataResult = Data()
            
            var state = UploadReceiptState()
            state.domainState.attachedImages = [
                UploadReceipt.ImageModel(data: Data(), uiData: UIImage()),
                UploadReceipt.ImageModel(data: Data(), uiData: UIImage()),
                UploadReceipt.ImageModel(data: Data(), uiData: UIImage()),
                UploadReceipt.ImageModel(data: Data(), uiData: UIImage()),
                UploadReceipt.ImageModel(data: Data(), uiData: UIImage())
            ]
            self.configure(initialState: state)
        }
        
        // When
        await self.controller.execute(.imagePicked(image: UploadReceipt.ImageUIDataModel())).value
        
        // Then
        let lastShowToastMessage = self.mockWorker.lastShowToastMessage
        
        XCTAssertEqual(lastShowToastMessage, "최대 5장까지 첨부할 수 있습니다")
    }

    func test_사진선택완료_첨부된사진5개미만__첨부된이미지목록에추가됨() async {
        // Given
        await MainActor.run {
            self.mockWorker.mapToDataResult = Data()
            
            var state = UploadReceiptState()
            state.domainState.attachedImages = [
                UploadReceipt.ImageModel(data: Data(), uiData: UIImage()),
                UploadReceipt.ImageModel(data: Data(), uiData: UIImage()),
                UploadReceipt.ImageModel(data: Data(), uiData: UIImage()),
                UploadReceipt.ImageModel(data: Data(), uiData: UIImage())
            ]
            self.configure(initialState: state)
        }
        
        // When
        await self.controller.execute(.imagePicked(image: UploadReceipt.ImageUIDataModel())).value
        
        // Then
        let domainAttachedImages = await self.state.domainState.attachedImages
        let attachedImages = await self.state.attachedImages
        
        XCTAssertEqual(domainAttachedImages.count, 5)
        XCTAssertEqual(attachedImages.count, 5)
    }

    func test_다음버튼클릭_첨부된사진0개__토스트메세지표출됨() async {
        // Given
        await MainActor.run {
            var state = UploadReceiptState()
            state.domainState.attachedImages = []
            self.configure(initialState: state)
        }
        
        // When
        await self.controller.execute(.nextButtonTapped).value
        
        // Then
        let lastShowToastMessage = self.mockWorker.lastShowToastMessage
        
        XCTAssertEqual(lastShowToastMessage, "견적 요청을 하기 위해서\n필수로 이미지를 첨부하여야 합니다")
    }

    func test_다음버튼클릭_첨부된사진1개이상_이미지업로드url조회실패__토스트메세지표출됨() async {
        // Given
        await MainActor.run {
            var state = UploadReceiptState()
            state.domainState.attachedImages = [
                UploadReceipt.ImageModel(data: Data(), uiData: UIImage())
            ]
            self.configure(initialState: state)
            
            self.mockWorker.fetchImageUploadUrlsResult = .failure(NSError(domain: "Test", code: -999))
        }
        
        // When
        await self.controller.execute(.nextButtonTapped).value
        
        // Then
        let lastShowToastMessage = self.mockWorker.lastShowToastMessage
        
        XCTAssertEqual(lastShowToastMessage, "작업을 완료할 수 없습니다.(Test 오류 -999.)")
    }

    func test_다음버튼클릭_첨부된사진1개이상_이미지업로드url조회성공_이미지업로드실패__토스트메세지표출됨() async {
        // Given
        await MainActor.run {
            var state = UploadReceiptState()
            state.domainState.attachedImages = [
                UploadReceipt.ImageModel(data: Data(), uiData: UIImage())
            ]
            self.configure(initialState: state)
            
            self.mockWorker.fetchImageUploadUrlsResult = .success([])
            self.mockWorker.requestImagesUploadResult = .failure(NSError(domain: "Test", code: -999))
        }
        
        // When
        await self.controller.execute(.nextButtonTapped).value
        
        // Then
        let lastShowToastMessage = self.mockWorker.lastShowToastMessage
        
        XCTAssertEqual(lastShowToastMessage, "작업을 완료할 수 없습니다.(Test 오류 -999.)")
    }

    func test_다음버튼클릭_첨부된사진1개이상_이미지업로드url조회성공_이미지업로드성공__요청사항입력화면표출됨() async {
        // Given
        await MainActor.run {
            var state = UploadReceiptState()
            state.domainState.attachedImages = [
                UploadReceipt.ImageModel(data: Data(), uiData: UIImage())
            ]
            self.configure(initialState: state)
            
            self.mockWorker.fetchImageUploadUrlsResult = .success([])
            self.mockWorker.requestImagesUploadResult = .success(())
        }
        
        // When
        await self.controller.execute(.nextButtonTapped).value
        
        // Then
        let isAddRequestsViewActive = await self.state.isAddRequestsViewActive
        
        XCTAssertEqual(isAddRequestsViewActive, true)
    }
    
    func test_다음버튼클릭_첨부된사진1개이상_이미지업로드url조회성공_이미지업로드성공__요청사항입력화면이미지키값전달됨() async {
        // Given
        await MainActor.run {
            var state = UploadReceiptState()
            state.domainState.attachedImages = [
                UploadReceipt.ImageModel(data: Data(), uiData: UIImage())
            ]
            self.configure(initialState: state)
            
            self.mockWorker.fetchImageUploadUrlsResult = .success([.init(uploadUrl: "test", objectKey: "test")])
            self.mockWorker.requestImagesUploadResult = .success(())
        }
        
        // When
        await self.controller.execute(.nextButtonTapped).value
        
        // Then
        let receiptImageUploadUrlObjectKeys = await self.store.state.receiptImageUploadUrlObjectKeys
        
        XCTAssertEqual(receiptImageUploadUrlObjectKeys, ["test"])
    }

    func test_요청사항입력화면활성화여부변경_활성화__요청사항입력화면표출됨() async {
        // Given
        
        // When
        await self.controller.execute(.addRequestsViewIsActiveChanged(isActive: true)).value
        
        // Then
        let isAddRequestsViewActive = await self.state.isAddRequestsViewActive
        
        XCTAssertEqual(isAddRequestsViewActive, true)
    }

    func test_요청사항입력화면활성화여부변경_비활성화__요청사항입력화면표출되지않음() async {
        // Given
        
        // When
        await self.controller.execute(.addRequestsViewIsActiveChanged(isActive: false)).value
        
        // Then
        let isAddRequestsViewActive = await self.state.isAddRequestsViewActive
        
        XCTAssertEqual(isAddRequestsViewActive, false)
    }
}

// MARK: - Mock Classes

extension UploadReceiptSceneTests {
    
    class MockWorker: UploadReceiptWorkable {
        
        var delegate: UploadReceiptDelegate?
        
        var addRequestsController: AddRequestsControllerable?
        
        var mapToDataResult: Data?
        
        func mapToData(from imageUIData: UploadReceipt.ImageUIDataModel) -> Data? {
            return self.mapToDataResult
        }
        
        var fetchImageUploadUrlsResult: Result<[UploadReceipt.ImageUploadUrl], Error>?
        
        func fetchImageUploadUrls(names: [String]) async throws -> [UploadReceipt.ImageUploadUrl] {
            if let fetchImageUploadUrlsResult = self.fetchImageUploadUrlsResult {
                switch fetchImageUploadUrlsResult {
                case .success(let data):
                    return data
                case .failure(let error):
                    throw error
                }
            }
            XCTFail("fetchImageUploadUrls()의 결과값을 주입해주어야합니다.")
            return []
        }
        
        var requestImagesUploadResult: Result<Void, Error>?
        
        func requestImagesUpload(attatchedImages: [UploadReceipt.ImageModel], imageUploadUrls: [UploadReceipt.ImageUploadUrl]) async throws {
            if let requestImagesUploadResult = self.requestImagesUploadResult {
                switch requestImagesUploadResult {
                case .success(let data):
                    return data
                case .failure(let error):
                    throw error
                }
            }
            XCTFail("requestImagesUpload()의 결과값을 주입해주어야합니다.")
        }
        
        var requestCameraPermissionResult: Bool?
        
        func requestCameraPermission() async -> Bool {
            if let requestCameraPermissionResult = self.requestCameraPermissionResult {
                return requestCameraPermissionResult
            }
            XCTFail("requestCameraPermission()의 결과값을 주입해주어야합니다.")
            return false
        }
        
        var requestGalleryPermissionResult: Bool?
        
        func requestGalleryPermission() async -> Bool {
            if let requestGalleryPermissionResult = self.requestGalleryPermissionResult {
                return requestGalleryPermissionResult
            }
            XCTFail("requestGalleryPermission()의 결과값을 주입해주어야합니다.")
            return false
        }
        
        var saveImageResult: Result<Void, Error>?
        
        func saveImage(imageUIData: UploadReceipt.ImageUIDataModel) async throws {
            if let saveImageResult = self.saveImageResult {
                switch saveImageResult {
                case .success(let data):
                    return data
                case .failure(let error):
                    throw error
                }
            }
            XCTFail("saveImage()의 결과값을 주입해주어야합니다.")
        }
        
        var lastShowToastMessage: String?
        
        func showToast(message: String) {
            self.lastShowToastMessage = message
        }
    }
}
