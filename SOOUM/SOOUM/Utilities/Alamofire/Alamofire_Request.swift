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
}

enum AuthorizationType {
    case access
    case refresh
    case none
}
