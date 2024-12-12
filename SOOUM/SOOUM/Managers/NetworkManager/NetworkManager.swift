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
    func upload(
        _ data: Data,
        to url: URLConvertible
    ) -> Observable<Result<Void, Error>>
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
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
            /// UTC 기준
            formatter.timeZone = .Korea
            formatter.locale = .Korea
            
            self.decoder = JSONDecoder()
            self.decoder.dateDecodingStrategy = .formatted(formatter)
            self.encoder = JSONEncoder()
            self.encoder.dateEncodingStrategy = .formatted(formatter)
        }
    }
    
    init() {
        
        self.configuration = Configuration()
        self.session = .init(
            configuration: configuration.sessionConfiguration,
            interceptor: CompositeInterceptor(),
            eventMonitors: [LogginMonitor()]
        )
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
                    decoder: self?.decoder ?? JSONDecoder(),
                    emptyResponseCodes: [200, 201, 204, 205]
                ) { response in
                    switch response.result {
                    case .success(let value):
                        if let error = response.error {
                            observer.onError(error)
                        } else {
                            observer.onNext(value)
                            observer.onCompleted()
                        }
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
    
    func upload(
        _ data: Data,
        to url: URLConvertible
    ) -> Observable<Result<Void, Error>> {
        return Observable.create { [weak self] observer -> Disposable in
            
            let task = self?.session.upload(data, to: url, method: .put)
                .validate(statusCode: 200..<500)
                .response { response in
                    switch response.result {
                    case .success:
                        if let error = response.error {
                            observer.onError(error)
                        } else {
                            observer.onNext(.success(()))
                            observer.onCompleted()
                        }
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
