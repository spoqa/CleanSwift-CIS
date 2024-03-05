//
//  UploadReceiptView.swift
//  Example
//
//  Created by 박건우 on 2024/01/12.
//  Copyright (c) 2024 Spoqa. All rights reserved.
//

import AddRequestsScene
import NetworkService

import Combine
import UIKit

public final class UploadReceiptUIKitView: UIViewController {
    private var cancellables: Set<AnyCancellable> = []
    
    private let controller: (UploadReceiptControllerable & AddRequestsDelegate)
    private var store: UploadReceiptStore
    
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
        
        super.init(nibName: nil, bundle: nil)
        
        self.bind()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI
    
    private var titleLabel = UILabel()
    private var imageScrollView = UIScrollView()
    private var imageAttachButton = UIButton()
    private var nextButton = UIButton()
    private var imageViews = [UIImageView]()
    private var selectImageAttachmentMethodSheet = UIAlertController(title: "사진 추가하기", message: nil, preferredStyle: .actionSheet)
    private var imagePicker = UIImagePickerController()
    private var camera = UIImagePickerController()
    
    // MARK: - View lifecycle
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
    }
    
    // MARK: - Layout
    
    private func setupUI() {
        self.view.backgroundColor = .white
        
        // Navigation Setup
        self.title = "견적요청 - 명세표 업로드"

        // ScrollView Setup
        self.imageScrollView.translatesAutoresizingMaskIntoConstraints = false
        self.imageScrollView.showsHorizontalScrollIndicator = false
        self.view.addSubview(self.imageScrollView)

        // Attach Image Button Setup
        self.imageAttachButton.translatesAutoresizingMaskIntoConstraints = false
        self.imageAttachButton.setTitle("사진 첨부", for: .normal)
        self.imageAttachButton.setTitleColor(.blue, for: .normal)
        self.imageAttachButton.addTarget(self, action: #selector(imageAttachButtonTapped), for: .touchUpInside)
        self.imageAttachButton.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.imageAttachButton)

        // Next Button Setup
        self.nextButton.translatesAutoresizingMaskIntoConstraints = false
        self.nextButton.setTitle("다음", for: .normal)
        self.nextButton.backgroundColor = .blue
        self.nextButton.layer.cornerRadius = 10
        self.nextButton.addTarget(self, action: #selector(self.nextButtonTapped), for: .touchUpInside)
        self.nextButton.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.nextButton)
        
        // Action Sheet Setup
        self.selectImageAttachmentMethodSheet.addAction(UIAlertAction(title: "사진 촬영하기", style: .default) { _ in
            self.controller.execute(.imageAttachmentMethodCameraSelected)
        })
        self.selectImageAttachmentMethodSheet.addAction(UIAlertAction(title: "사진첩에서 가져오기", style: .default) { _ in
            self.controller.execute(.imageAttachmentMethodGallerySelected)
        })
        self.selectImageAttachmentMethodSheet.addAction(UIAlertAction(title: "취소", style: .cancel))
        
        // ImagePicker & Camera Setup
        self.imagePicker.delegate = self
        self.imagePicker.sourceType = .photoLibrary
        self.camera.delegate = self
        self.camera.sourceType = .camera

        // Auto Layout Constraints
        NSLayoutConstraint.activate([
            self.imageScrollView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 20),
            self.imageScrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10),
            self.imageScrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10),
            self.imageScrollView.heightAnchor.constraint(equalToConstant: 100),

            self.imageAttachButton.topAnchor.constraint(equalTo: self.imageScrollView.bottomAnchor, constant: 10),
            self.imageAttachButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10),
            self.imageAttachButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10),
            self.imageAttachButton.heightAnchor.constraint(equalToConstant: 50),

            self.nextButton.topAnchor.constraint(equalTo: self.imageAttachButton.bottomAnchor, constant: 10),
            self.nextButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10),
            self.nextButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10),
            self.nextButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    // MARK: - Bind
    
    private func bind() {
        
        self.store.$state
            .map { $0.attachedImages }
            .sink { [weak self] attachedImages in
                self?.updateImageScrollView(with: attachedImages)
            }
            .store(in: &self.cancellables)
        
        self.store.$state
            .map { $0.showingSelectImageAttachmentMethodSheet }
            .removeDuplicates()
            .sink { [weak self] showingSelectImageAttachmentMethodSheet in
                guard let self = self else {
                    return
                }
                if showingSelectImageAttachmentMethodSheet {
                    self.present(self.selectImageAttachmentMethodSheet, animated: true)
                }
                else {
                    self.selectImageAttachmentMethodSheet.dismiss(animated: true)
                }
            }
            .store(in: &self.cancellables)
        
        self.store.$state
            .map { $0.showingImagePicker }
            .removeDuplicates()
            .sink { [weak self] showingImagePicker in
                guard let self = self else {
                    return
                }
                if showingImagePicker {
                    self.present(self.imagePicker, animated: true, completion: nil)
                }
                else {
                    self.imagePicker.dismiss(animated: true)
                }
            }
            .store(in: &self.cancellables)
        
        self.store.$state
            .map { $0.showingCamera }
            .removeDuplicates()
            .sink { [weak self] showingCamera in
                guard let self = self else {
                    return
                }
                if showingCamera {
                    self.present(self.camera, animated: true, completion: nil)
                }
                else {
                    self.camera.dismiss(animated: true)
                }
            }
            .store(in: &self.cancellables)
        
        // MARK: - Bind AddReuqests
        
        self.store.$state
            .map { $0.isAddRequestsViewActive }
            .removeDuplicates()
            .sink { [weak self] isActive in
                guard let self = self else {
                    return
                }
                if isActive {
                    let addRequestsView = AddRequestsUIKitView(
                        initialState: AddRequestsState(
                            receiptImageUploadUrlObjectKeys: self.store.state.receiptImageUploadUrlObjectKeys
                        ),
                        controller: &self.store.worker.addRequestsController,
                        delegate: self.controller
                    ) { [weak self] isActive in
                        self?.controller.execute(.addRequestsViewIsActiveChanged(isActive: isActive))
                    }
                    self.navigationController?.pushViewController(addRequestsView, animated: true)
                }
                else {
                    self.navigationController?.removeViewControllersAbove(baseViewController: self, ofType: AddRequestsUIKitView.self)
                }
            }
            .store(in: &self.cancellables)
    }
    
    private func updateImageScrollView(with images: [UIImage]) {
        self.imageViews.forEach {
            $0.removeFromSuperview()
        }
        self.imageViews = images.map { image in
            let imageView = UIImageView(image: image)
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            return imageView
        }
        let stackView = UIStackView(arrangedSubviews: imageViews)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.alignment = .center

        self.imageScrollView.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: self.imageScrollView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: self.imageScrollView.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: self.imageScrollView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: self.imageScrollView.trailingAnchor),
            stackView.heightAnchor.constraint(equalTo: self.imageScrollView.heightAnchor)
        ])

        self.imageViews.forEach { imageView in
            NSLayoutConstraint.activate([
                imageView.widthAnchor.constraint(equalToConstant: 100),
                imageView.heightAnchor.constraint(equalToConstant: 100)
            ])
        }
    }
    
    // MARK: - Action Selector
    
    @objc private func imageAttachButtonTapped() {
        self.controller.execute(.imageAttachTapped)
    }

    @objc private func nextButtonTapped() {
        self.controller.execute(.nextButtonTapped)
    }
}

extension UploadReceiptUIKitView: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage else {
            return
        }
        switch picker.sourceType {
        case .camera:
            self.controller.execute(.cameraPhotoTakenCompleted(image: image))
            
        case .photoLibrary:
            self.controller.execute(.imagePicked(image: image))
            
        default:
            break
        }
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        switch picker.sourceType {
        case .camera:
            self.controller.execute(.cameraCanceled)
            
        case .photoLibrary:
            self.controller.execute(.imagePickerCanceled)
            
        default:
            break
        }
    }
}

// MARK: - Utils

extension UINavigationController {
    
    func removeViewControllersAbove<T: UIViewController>(baseViewController: UIViewController, ofType viewControllerTypeToRemove: T.Type) {
        var viewControllers = self.viewControllers
        
        if let baseIndex = viewControllers.firstIndex(of: baseViewController) {
            var controllersToKeep = Array(viewControllers.prefix(through: baseIndex))
            
            for controller in viewControllers.suffix(from: baseIndex + 1) {
                if !(controller is T) {
                    controllersToKeep.append(controller)
                }
            }
            
            viewControllers = controllersToKeep
        }
        
        self.setViewControllers(viewControllers, animated: true)
    }
}
