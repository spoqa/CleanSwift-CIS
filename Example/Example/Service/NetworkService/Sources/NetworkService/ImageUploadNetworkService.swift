//
//  ImageUploadNetworkService.swift
//  
//
//  Created by 박건우 on 2023/12/22.
//

import Foundation

public protocol ImageUploadNetworkServiceProtocol {
    func queryImageUploadUrls(fileNames: [String]) async throws -> UploadUrlsDTO
    func putImageData(to url: String, imageData: Data) async throws
}

public final class ImageUploadNetworkService: ImageUploadNetworkServiceProtocol {
    
    public init() {}
    
    public func queryImageUploadUrls(fileNames: [String]) async throws -> UploadUrlsDTO {
        return UploadUrlsDTO(uploadUrls: [
            UploadUrlDTO(uploadUrl: "", objectKey: ""),
            UploadUrlDTO(uploadUrl: "", objectKey: ""),
            UploadUrlDTO(uploadUrl: "", objectKey: ""),
            UploadUrlDTO(uploadUrl: "", objectKey: ""),
            UploadUrlDTO(uploadUrl: "", objectKey: "")
        ])
    }
    
    public func putImageData(to url: String, imageData: Data) async throws {
        
    }
}
