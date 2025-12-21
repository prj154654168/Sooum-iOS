//
//  AddingTokenInterceptor.swift
//  SOOUM
//
//  Created by 오현식 on 1/15/25.
//

import Alamofire

final class AddingTokenInterceptor: RequestInterceptor {
    
    private let provider: ManagerTypeDelegate
    
    init(provider: ManagerTypeDelegate) {
        self.provider = provider
    }
    
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, any Error>) -> Void) {
        var request = urlRequest
        let authorizationType = request.value(forHTTPHeaderField: "AuthorizationType")
        
        switch authorizationType {
        case "access":
            let authPayloadForAccess = self.provider.authManager.authPayloadByAccess()
            let authKeyForAccess = authPayloadForAccess.keys.first! as String
            request.setValue(authPayloadForAccess[authKeyForAccess], forHTTPHeaderField: authKeyForAccess)
        case "refresh":
            let authPayloadForRefresh = self.provider.authManager.authPayloadByRefresh()
            let authKeyForRefresh = authPayloadForRefresh.keys.first! as String
            request.setValue(authPayloadForRefresh[authKeyForRefresh], forHTTPHeaderField: authKeyForRefresh)
        default:
            break
        }
        
        completion(.success(request))
    }
}
