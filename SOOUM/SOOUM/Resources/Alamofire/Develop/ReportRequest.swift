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
    

    var path: String {
        switch self {
        case let .reportCard(id, _):
            return "/report/cards/\(id)"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .reportCard:
            return .post
        }
    }

    var parameters: Parameters {
        switch self {
        case let .reportCard(_, reportType):
            return ["reportType": reportType.rawValue]
        }
    }

    var encoding: ParameterEncoding {
        switch self {
        case .reportCard:
            return URLEncoding.queryString
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
