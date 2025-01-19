//
//  PresignedStorageResponse.swift
//  SOOUM
//
//  Created by JDeoks on 10/25/24.
//

import Foundation

import Alamofire


struct PresignedStorageResponse: Codable {
    
    let imgName: String
    let url: URLString
    let status: Status
}

extension PresignedStorageResponse {
    
    init() {
        self.imgName = ""
        self.url = .init()
        self.status = .init()
    }
}

extension PresignedStorageResponse: EmptyResponse {
    
    static func emptyValue() -> PresignedStorageResponse {
        PresignedStorageResponse()
    }
}
