//
//  SceneDelegate.swift
//  Example
//
//  Created by 박건우 on 2023/12/22.
//

import UploadReceiptScene

import SwiftUI


class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    weak var uploadReceiptController: UploadReceiptControllerable?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            
            // SwiftUI
            let uploadReceiptView = UploadReceiptSwiftUIView(
                initialState: UploadReceiptState(),
                controller: &self.uploadReceiptController,
                delegate: self
            )
            window.rootViewController = UIHostingController(rootView: uploadReceiptView)
            
            // UIKit
//            let uploadReceiptView = UploadReceiptUIKitView(
//                initialState: UploadReceiptState(),
//                controller: &self.uploadReceiptController,
//                delegate: self
//            )
//            window.rootViewController = UINavigationController(rootViewController: uploadReceiptView)
            
            self.window = window
            window.makeKeyAndVisible()
        }
    }
}

extension SceneDelegate: UploadReceiptDelegate {
    
}
