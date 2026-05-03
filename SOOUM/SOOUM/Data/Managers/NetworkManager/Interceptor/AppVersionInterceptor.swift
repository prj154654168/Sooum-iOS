//
//  AppVersionInterceptor.swift
//  SOOUM
//
//  Created by Codex on 5/3/26.
//

import Foundation

import Alamofire

final class AppVersionInterceptor: RequestInterceptor {
    
    enum Header {
        static let appVersion: String = "version"
    }
    
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, any Error>) -> Void) {
        var request = urlRequest
        request.setValue(self.currentAppVersion(), forHTTPHeaderField: Header.appVersion)
        completion(.success(request))
    }
}

private extension AppVersionInterceptor {
    
    func currentAppVersion() -> String {
        return Info.appVersion
    }
}
