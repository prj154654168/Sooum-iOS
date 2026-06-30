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
            self.sessionConfiguration.timeoutIntervalForRequest = 10.0
            self.sessionConfiguration.timeoutIntervalForResource = 10.0
            
            self.sessionDelegate = sessionDelegate
            self.sessionDelegateQueue = sessionDelegateQueue
            
            let fullFormatter = DateFormatter()
            fullFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
            fullFormatter.locale = .Korea
            fullFormatter.timeZone = .Korea
            
            let timezoneFormatter = DateFormatter()
            timezoneFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSXXXXX"
            timezoneFormatter.locale = .Korea
            timezoneFormatter.timeZone = .Korea
            
            let secondFormatter = DateFormatter()
            secondFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            secondFormatter.locale = .Korea
            secondFormatter.timeZone = .Korea
            
            let timezoneSecondFormatter = DateFormatter()
            timezoneSecondFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssXXXXX"
            timezoneSecondFormatter.locale = .Korea
            timezoneSecondFormatter.timeZone = .Korea
            
            let shortFormatter = DateFormatter()
            shortFormatter.dateFormat = "yyyy-MM-dd"
            shortFormatter.locale = .Korea
            shortFormatter.timeZone = .Korea
            
            let iso8601Formatter = ISO8601DateFormatter()
            iso8601Formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            iso8601Formatter.timeZone = .Korea
            
            let iso8601WithoutFractionalSecondsFormatter = ISO8601DateFormatter()
            iso8601WithoutFractionalSecondsFormatter.formatOptions = [.withInternetDateTime]
            iso8601WithoutFractionalSecondsFormatter.timeZone = .Korea
            
            self.decoder = JSONDecoder()
            self.decoder.dateDecodingStrategy = .custom { decoder in
                let singleContainer = try decoder.singleValueContainer()
                let dateString = try singleContainer.decode(String.self)
                
                if let date = fullFormatter.date(from: dateString) {
                    return date
                }
                
                if let date = timezoneFormatter.date(from: dateString) {
                    return date
                }
                
                if let date = secondFormatter.date(from: dateString) {
                    return date
                }
                
                if let date = timezoneSecondFormatter.date(from: dateString) {
                    return date
                }
                
                if let date = iso8601Formatter.date(from: dateString) {
                    return date
                }
                
                if let date = iso8601WithoutFractionalSecondsFormatter.date(from: dateString) {
                    return date
                }
                
                if let date = shortFormatter.date(from: dateString) {
                    return date
                }
                
                throw DecodingError.dataCorruptedError(
                    in: singleContainer,
                    debugDescription: "Date string \(dateString) cannot be decoded"
                )
            }
            self.encoder = JSONEncoder()
            self.encoder.dateEncodingStrategy = .formatted(fullFormatter)
        }
    }
    
    init() {
        self.configuration = Configuration()
    }
}
