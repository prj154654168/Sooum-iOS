//
//  Alamofire_constants.swift
//  SOOUM
//
//  Created by 오현식 on 9/23/24.
//

import Foundation


struct Constants {
    
    static func serverEndpoint(scheme: String) -> String {
        return scheme + (Bundle.main.infoDictionary?["ServerEndpoint"] as? String)!
    }
    
    static var endpoint: String {
        return self.serverEndpoint(scheme: "https://")
    }
    
    enum HTTPHeader: String {
        case contentType = "Content-Type"
        case acceptType = "Accept"
    }
    
    enum ContentType: String {
        case json = "application/json"
    }
}
