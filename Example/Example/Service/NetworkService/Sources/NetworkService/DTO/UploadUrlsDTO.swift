//
//  UploadUrlsDTO.swift
//  
//
//  Created by 박건우 on 2023/12/22.
//

import Foundation

public struct UploadUrlsDTO: Codable {
    public let uploadUrls: [UploadUrlDTO]
}

public struct UploadUrlDTO: Codable {
    public let uploadUrl: String
    public let objectKey: String
}
