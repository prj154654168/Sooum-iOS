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
    
    // TODO: 앱 심사 중 사용할 endpoint
    var serverEndpoint: String { get }
}

enum AuthorizationType: String {
    case access
    case refresh
    case none
}
