//
//  UploadReceiptModels.swift
//  Example
//
//  Created by 박건우 on 2023/12/21.
//  Copyright (c) 2023 Spoqa. All rights reserved.
//

import SwiftUI
import UIKit

public enum UploadReceipt {
    
    // MARK: - Entities
    
    public struct ImageModel: Equatable {
        let name: String = "\(Date().timeIntervalSince1970)_\(UUID())"
        let data: Data
        let uiData: ImageUIDataModel
    }
    
    public struct ImageUploadUrl {
        let uploadUrl: String
        let objectKey: String
    }
    
    // MARK: - ViewModels
    
    public typealias ImageUIDataModel = UIImage
    
    // MARK: - UseCases
    
    enum AttachImage {
        
        struct Request {
            let imageUIData: ImageUIDataModel
        }
        
        struct Response {
            let attachedImages: [ImageModel]
            let error: Error?
            
            enum Error {
                case exceedImageCount
                case failDataMapping
            }
        }
    }
    
    enum UploadImage {
        
        struct Request {
            
        }
        
        struct Response {
            let uploadUrlObjectKeys: [String]
            let error: Error?
            
            enum Error {
                case emptyAttachedImage
                case `default`(Swift.Error)
            }
        }
    }
    
    enum SaveImage {
        
        struct Request {
            let imageUIData: ImageUIDataModel
        }
        
        struct Response {
            let error: Error?
        }
    }
    
    enum ShowCamera {
        
        struct Request {
            
        }
        
        struct Response {
            let permissionDenied: Bool
        }
    }
    
    enum ShowGallery {
        
        struct Request {
            
        }
        
        struct Response {
            let permissionDenied: Bool
        }
    }
}
