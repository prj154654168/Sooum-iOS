//
//  ReportRequest.swift
//  SOOUM
//
//  Created by JDeoks on 10/15/24.
//

import Foundation

import Alamofire


enum ReportRequest: BaseRequest {

    case reportCard(id: String, reportType: ReportViewReactor.ReportType)
    case blockMember(id: String)
    case cancelBlockMember(id: String)
    

    var path: String {
        switch self {
        case let .reportCard(id, _):
            return "/report/cards/\(id)"
        case .blockMember:
            return "/blocks"
        case let .cancelBlockMember(id):
            return "/blocks/\(id)"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .cancelBlockMember:
            return .delete
        default:
            return .post
        }
    }

    var parameters: Parameters {
        switch self {
        case let .reportCard(_, reportType):
            return ["reportType": reportType.rawValue]
        case let .blockMember(id):
            return ["toMemberId": id]
        case .cancelBlockMember:
            return [:]
        }
    }

    var encoding: ParameterEncoding {
        switch self {
        case .cancelBlockMember:
            return URLEncoding.default
        default:
            return JSONEncoding.default
        }
    }
    
    var authorizationType: AuthorizationType {
        switch self {
        default:
            return .access
        }
    }

    func asURLRequest() throws -> URLRequest {

        if let url = URL(string: Constants.endpoint)?.appendingPathComponent(self.path) {
            var request = URLRequest(url: url)
            request.method = self.method
            
            let authPayload = AuthManager.shared.authPayloadByAccess()
            let authKey = authPayload.keys.first! as String
            request.setValue(authPayload[authKey], forHTTPHeaderField: authKey)
            
            request.setValue(
                Constants.ContentType.json.rawValue,
                forHTTPHeaderField: Constants.HTTPHeader.contentType.rawValue
            )
            request.setValue(
                Constants.ContentType.json.rawValue,
                forHTTPHeaderField: Constants.HTTPHeader.acceptType.rawValue
            )
            let encoded = try encoding.encode(request, with: self.parameters)
            return encoded
        } else {
            return URLRequest(url: URL(string: "")!)
        }
    }
}
