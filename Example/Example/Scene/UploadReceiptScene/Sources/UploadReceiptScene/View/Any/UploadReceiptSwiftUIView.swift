//
//  UploadReceiptView.swift
//  Example
//
//  Created by 박건우 on 2023/12/21.
//  Copyright (c) 2023 Spoqa. All rights reserved.
//

import AddRequestsScene
import NetworkService

import SwiftUI

public struct UploadReceiptSwiftUIView: View {
    
    private let controller: (UploadReceiptControllerable & AddRequestsDelegate)
    @ObservedObject private var store: UploadReceiptStore
    
    public init(
        initialState: UploadReceiptState,
        controller: inout UploadReceiptControllerable?,
        delegate: UploadReceiptDelegate
    ) {
        let imageUploadNetworkService = ImageUploadNetworkService()
        let worker = UploadReceiptWorker(delegate: delegate, imageUploadNetworkService: imageUploadNetworkService)
        let store = UploadReceiptStore(worker: worker, state: initialState)
        let interactor = UploadReceiptInteractor(store: store, worker: worker)
        let _controller = UploadReceiptController(interactor: interactor, store: store)
        controller = _controller
        
        self.controller = _controller
        self.store = store
    }
    
    public var body: some View {
        NavigationView {
            VStack {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(self.store.state.attachedImages, id: \.self) { image in
                            Image(uiImage: image)
                                .resizable()
                                .frame(width: 100, height: 100)
                                .cornerRadius(10)
                                .padding(.trailing, 10)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 10)
                .padding(.top, 20)
                .padding(.bottom, 10)
                
                Text("사진 첨부")
                    .foregroundColor(.blue)
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .cornerRadius(10)
                    .padding(.horizontal, 10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(.blue, lineWidth: 1)
                            .padding(.horizontal, 10)
                    )
                    .onTapGesture {
                        self.controller.execute(.imageAttachTapped)
                    }
                
                Text("다음")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .background(Color.blue)
                    .cornerRadius(10)
                    .padding(.horizontal, 10)
                    .onTapGesture {
                        self.controller.execute(.nextButtonTapped)
                    }
                
                Spacer()
                
                NavigationLink(
                    isActive: Binding(
                        get: {
                            return self.store.state.isAddRequestsViewActive
                        },
                        set: { isActive in
                            self.controller.execute(.addRequestsViewIsActiveChanged(isActive: isActive))
                        }
                    ),
                    destination: {
                        AddRequestsSwiftUIView(
                            initialState: AddRequestsState(
                                receiptImageUploadUrlObjectKeys: self.store.state.receiptImageUploadUrlObjectKeys
                            ),
                            controller: &self.store.worker.addRequestsController,
                            delegate: self.controller
                        )
                    }
                ) {
                    EmptyView()
                }
            }
            .navigationBarTitle("견적요청 - 명세표 업로드", displayMode: .inline)
            .actionSheet(isPresented: Binding(
                get: {
                    return self.store.state.showingSelectImageAttachmentMethodSheet
                },
                set: { _ in
                    
                }
            )) {
                ActionSheet(
                    title: Text("사진 추가하기"),
                    buttons: [
                        .default(Text("사진 촬영하기")) {
                            self.controller.execute(.imageAttachmentMethodCameraSelected)
                        },
                        .default(Text("사진첩에서 가져오기")) {
                            self.controller.execute(.imageAttachmentMethodGallerySelected)
                        },
                        .cancel()
                    ]
                )
            }
            .sheet(isPresented: Binding(
                get: {
                    return self.store.state.showingImagePicker
                },
                set: { _ in
                    
                }
            )) {
                ImagePickerController(controller: self.controller, sourceType: .photoLibrary)
            }
            .sheet(isPresented: Binding(
                get: {
                    return self.store.state.showingCamera
                },
                set: { _ in
                    
                }
            )) {
                ImagePickerController(controller: self.controller, sourceType: .camera)
            }
        }
    }
}

struct ImagePickerController: UIViewControllerRepresentable {
    
    weak var controller: UploadReceiptControllerable?
    
    var sourceType: UIImagePickerController.SourceType
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        weak var controller: UploadReceiptControllerable?

        init(_ controller: UploadReceiptControllerable?) {
            self.controller = controller
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            guard let image = info[.originalImage] as? UIImage else {
                return
            }
            switch picker.sourceType {
            case .camera:
                self.controller?.execute(.cameraPhotoTakenCompleted(image: image))
                
            case .photoLibrary:
                self.controller?.execute(.imagePicked(image: image))
                
            default:
                break
            }
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            switch picker.sourceType {
            case .camera:
                self.controller?.execute(.cameraCanceled)
                
            case .photoLibrary:
                self.controller?.execute(.imagePickerCanceled)
                
            default:
                break
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self.controller)
    }

    func makeUIViewController(context: Context) -> UIViewController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = sourceType
        return picker
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {

    }
}
