//
//  DefinedError.swift
//  SOOUM
//
//  Created by 오현식 on 4/1/25.
//

import Foundation

import Alamofire


enum DefinedError: Error, LocalizedError {
    case badRequest
    case unauthorized
    case payment
    case forbidden
    case notFound
    case teapot
    case invlid
    case locked
    case invalidMethod(HTTPMethod)
    case unknown(Int)
    
    static func error(with statusCode: Int) -> Self {
        switch statusCode {
        case 400:
            return .badRequest
        case 401:
            return .unauthorized
        case 402:
            return .payment
        case 403:
            return .forbidden
        case 404:
            return .notFound
        case 418:
            return .teapot
        case 422:
            return .invlid
        case 423:
            return .locked
        default:
            return .unknown(statusCode)
        }
    }
    
    var errorDescription: String {
        switch self {
        case .badRequest:
            return "Bad Request: HTTP 400 received."
        case .unauthorized:
            return "Unauthorization: HTTP 401 received."
        case .payment:
            return "Delete parent card: HTTP 402 received."
        case .forbidden:
            return "Expire RefreshToken: HTTP 403 received."
        case .notFound:
            return "Not Found: HTTP 404 received"
        case .teapot:
            return "Stop using RefreshToken: HTTP 418 received."
        case .invlid:
            return "Invlid Image: HTTP 422 received."
        case .locked:
            return "LOCKED: HTTP 423 received."
        case let .invalidMethod(httpMethod):
            return "Invalid Method: HTTPMethod \(httpMethod) was not expected"
        case let .unknown(statusCode):
            return "Unknown error: HTTP \(statusCode) received."
        }
    }
    
    func toNSError() -> NSError {
        let code = switch self {
        case .badRequest: 400
        case .unauthorized: 401
        case .payment: 402
        case .forbidden: 403
        case .notFound: 404
        case .teapot: 418
        case .invlid: 422
        case .locked: 423
        case .invalidMethod: -99
        case let .unknown(statusCode): statusCode
        }
        
        return NSError(
            domain: "SOOUM",
            code: code,
            userInfo: [NSLocalizedDescriptionKey: self.errorDescription]
        )
    }
}
