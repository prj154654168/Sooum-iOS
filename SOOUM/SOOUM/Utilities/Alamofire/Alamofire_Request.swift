//
//  Alamofire_Request.swift
//  SOOUM
//
//  Created by 오현식 on 9/23/24.
//

import Foundation

import Alamofire


protocol BaseRequest: URLRequestConvertible {
    
    var method: HTTPMethod { get }
    var path: String { get }
    var parameters: Parameters { get }
    var encoding: ParameterEncoding { get }
    var authorizationType: AuthorizationType { get }
    var version: APIVersion { get }
}

enum APIVersion: String {
    case v1 = ""
    case v2 = "/v2"
}

enum AuthorizationType: String {
    case access
    case refresh
    case none
}
