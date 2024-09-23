//
//  NetworkManager.swift
//  SOOUM
//
//  Created by 오현식 on 9/23/24.
//

import Foundation

import Alamofire
import RxSwift


protocol NetworkManagerDelegate: AnyObject {
    
    func request<T: Decodable>(_ object: T.Type, request: BaseRequest) -> Observable<T>
    func upload<T: Decodable>(
        _ object: T.Type,
        request: BaseRequest,
        multipartFormData: @escaping (MultipartFormData) -> Void
    ) -> Observable<T>
    func download<T: Decodable>(_ object: T.Type, request: BaseRequest) -> Observable<(T, URL)>
}

class NetworkManager {
    
    static let shared = NetworkManager()
    
    let configuration: Configuration
    /// URLSession in Alamofire
    let session: Session
    
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    
    struct Configuration {
        /// `URLSessionConfiguration.default`
        var sessionConfiguration: URLSessionConfiguration
        /// URLSession delegate that allows you to monitor the underlying URLSession
        var sessionDelegate: URLSessionDelegate?
        /// Overrides the default delegate queue
        var sessionDelegateQueue: OperationQueue?
        /// By default, uses `.millisecondsSince1970` date decoding strategy
        var decoder: JSONDecoder
        /// By default, uses `.millisecondsSince1970` date encoding strategy
        var encoder: JSONEncoder
        
        /// Initializes the configuration
        init(
            sessionConfiguration: URLSessionConfiguration = .default,
            sessionDelegate: URLSessionDelegate? = nil,
            sessionDelegateQueue: OperationQueue? = nil
        ) {
            
            self.sessionConfiguration = sessionConfiguration
            self.sessionDelegate = sessionDelegate
            self.sessionDelegateQueue = sessionDelegateQueue
            self.decoder = JSONDecoder()
            self.decoder.dateDecodingStrategy = .millisecondsSince1970
            self.encoder = JSONEncoder()
            self.encoder.dateEncodingStrategy = .millisecondsSince1970
        }
    }
    
    init() {
        
        self.configuration = Configuration()
        self.session = .init(configuration: configuration.sessionConfiguration)
        self.decoder = configuration.decoder
        self.encoder = configuration.encoder
    }
    
    private func setupError(_ message: String) -> NSError {
        
        let error: NSError = .init(
            domain: "SOOUM",
            code: -99,
            userInfo: [NSLocalizedDescriptionKey: message]
        )
        return error
    }
}

extension NetworkManager: NetworkManagerDelegate {
    
    func request<T: Decodable>(_ object: T.Type, request: BaseRequest) -> Observable<T> {
        return Observable.create { [weak self] observer -> Disposable in
            
            let task = self?.session.request(request)
                .validate(statusCode: 200..<500)
                .responseDecodable(
                    of: object,
                    decoder: self?.decoder ?? JSONDecoder()
                ) { response in
                    switch response.result {
                    case .success(let value):
                        
                        guard let httpResponse = response.response else {
                            
                            let error: NSError = self?.setupError("❌ No HTTPResponse") ?? .init()
                            observer.onError(error)
                            return
                        }
                        
                        guard (200..<300).contains(httpResponse.statusCode) else {
                            
                            let error: NSError = self?.setupError(
                                "❌ Unacceptable status code: \(httpResponse.statusCode)"
                            ) ?? .init()
                            observer.onError(error)
                            return
                        }
                        
                        if let error = response.error {
                            
                            let error: NSError = self?.setupError(
                                "❌ Alamofire errors: \(error)"
                            ) ?? .init()
                            observer.onError(error)
                        }
                        
                        observer.onNext(value)
                        observer.onCompleted()
                    case .failure(let error):
                        print("❌ Network or response format error: \(error)")
                        observer.onError(error)
                    }
                }
            
            return Disposables.create {
                task?.cancel()
            }
        }
    }
    
    func upload<T: Decodable>(
        _ object: T.Type,
        request: BaseRequest,
        multipartFormData: @escaping (Alamofire.MultipartFormData) -> Void
    ) -> Observable<T> {
        return Observable.create { [weak self] observer -> Disposable in
            
            let task = self?.session.upload(multipartFormData: multipartFormData, with: request)
                .validate(statusCode: 200..<500)
                .responseDecodable(
                    of: object,
                    decoder: self?.decoder ?? JSONDecoder()
                ) { response in
                    switch response.result {
                    case .success(let value):
                        
                        guard let httpResponse = response.response else {
                            
                            let error: NSError = self?.setupError("❌ No HTTPResponse") ?? .init()
                            observer.onError(error)
                            return
                        }
                        
                        guard (200..<300).contains(httpResponse.statusCode) else {
                            
                            let error: NSError = self?.setupError(
                                "❌ Unacceptable status code: \(httpResponse.statusCode)"
                            ) ?? .init()
                            observer.onError(error)
                            return
                        }
                        
                        if let error = response.error {
                            
                            let error: NSError = self?.setupError(
                                "❌ Alamofire errors: \(error)"
                            ) ?? .init()
                            observer.onError(error)
                        }
                        
                        observer.onNext(value)
                        observer.onCompleted()
                    case .failure(let error):
                        print("❌ Network or response format error: \(error)")
                        observer.onError(error)
                    }
                }
            
            return Disposables.create {
                task?.cancel()
            }
        }
    }
    
    func download<T: Decodable>(_ object: T.Type, request: BaseRequest) -> Observable<(T, URL)> {
        return Observable.create { [weak self] observer -> Disposable in
            
            let task = self?.session.download(request)
                .validate(statusCode: 200..<500)
                .responseDecodable(
                    of: object,
                    decoder: self?.decoder ?? JSONDecoder()
                ) { response in
                    switch response.result {
                    case .success(let value):
                        
                        guard let httpResponse = response.response,
                              let fileURL = response.fileURL else {
                            
                            let error: NSError = self?.setupError("❌ No HTTPResponse") ?? .init()
                            observer.onError(error)
                            return
                        }
                        
                        guard (200..<300).contains(httpResponse.statusCode) else {
                            
                            let error: NSError = self?.setupError(
                                "❌ Unacceptable status code: \(httpResponse.statusCode)"
                            ) ?? .init()
                            observer.onError(error)
                            return
                        }
                        
                        if let error = response.error {
                            
                            let error: NSError = self?.setupError(
                                "❌ Alamofire errors: \(error)"
                            ) ?? .init()
                            observer.onError(error)
                        }
                        
                        observer.onNext((value, fileURL))
                        observer.onCompleted()
                    case .failure(let error):
                        print("❌ Network or response format error: \(error)")
                        observer.onError(error)
                    }
                }
            
            return Disposables.create {
                task?.cancel()
            }
        }
    }
}
