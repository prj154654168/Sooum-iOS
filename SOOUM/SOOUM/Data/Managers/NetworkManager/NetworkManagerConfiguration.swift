//
//  NetworkManagerConfiguration.swift
//  SOOUM
//
//  Created by 오현식 on 1/26/25.
//

import Foundation


struct NetworkManagerConfiguration: ManagerConfiguration {
    
    private(set) var configuration: Configuration
    
    struct Configuration {
        /// `URLSessionConfiguration.default`
        var sessionConfiguration: URLSessionConfiguration
        /// URLSession delegate that allows you to monitor the underlying URLSession
        var sessionDelegate: URLSessionDelegate?
        /// Overrides the default delegate queue
        var sessionDelegateQueue: OperationQueue?
        /// By default, uses `yyyy-MM-dd'T'HH:mm:ss.SSSSSS` date decoding strategy
        var decoder: JSONDecoder
        /// By default, uses `yyyy-MM-dd'T'HH:mm:ss.SSSSSS` date encoding strategy
        var encoder: JSONEncoder
        
        /// Initializes the configuration
        init(
            sessionConfiguration: URLSessionConfiguration = .default,
            sessionDelegate: URLSessionDelegate? = nil,
            sessionDelegateQueue: OperationQueue? = nil
        ) {
            
            self.sessionConfiguration = sessionConfiguration
            self.sessionConfiguration.timeoutIntervalForRequest = 20.0
            self.sessionConfiguration.timeoutIntervalForResource = 20.0
            
            self.sessionDelegate = sessionDelegate
            self.sessionDelegateQueue = sessionDelegateQueue
            
            self.decoder = JSONDecoder()
            self.decoder.dateDecodingStrategy = .iso8601
            self.encoder = JSONEncoder()
            self.encoder.dateEncodingStrategy = .iso8601
        }
    }
    
    init() {
        self.configuration = Configuration()
    }
}
