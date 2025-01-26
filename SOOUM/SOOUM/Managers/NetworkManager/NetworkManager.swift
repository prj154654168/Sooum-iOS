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
    
    func checkClientVersion() -> Observable<String>
}

class NetworkManager: CompositeManager<NetworkManagerConfiguration> {
    
    let configuration: NetworkManagerConfiguration.Configuration
    /// URLSession in Alamofire
    let session: Session
    
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    
    override init(provider: ManagerTypeDelegate, configure: NetworkManagerConfiguration) {
        self.configuration = configure.configuration
        self.session = .init(
            configuration: configure.configuration.sessionConfiguration,
            interceptor: CompositeInterceptor(provider: provider),
            eventMonitors: [LogginMonitor()]
        )
        self.decoder = configure.configuration.decoder
        self.encoder = configure.configuration.encoder
        
        super.init(provider: provider, configure: configure)
    }
    
    private func setupError(_ message: String, with code: Int = -99) -> NSError {
        
        let error: NSError = .init(
            domain: "SOOUM",
            code: code,
            userInfo: [NSLocalizedDescriptionKey: message]
        )
        return error
    }
}

extension NetworkManager: NetworkManagerDelegate {
    
    
    // MARK: Request network sevice
    
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
                    case let .success(value):
                        if let error = response.error {
                            observer.onError(error)
                        } else {
                            observer.onNext(value)
                            observer.onCompleted()
                        }
                    case let .failure(error):
                        let statusCode = response.response?.statusCode
                        switch statusCode {
                        case 400:
                            let nsError = self?.setupError("Bad Request: HTTP 400 received.", with: 400) ?? .init()
                            observer.onError(nsError)
                            return
                        case 403:
                            let nsError = self?.setupError("Expire RefreshToken: HTTP 403 received,", with: 403) ?? .init()
                            observer.onError(nsError)
                            return
                        case 418:
                            let nsError = self?.setupError("Stop using RefreshToken: HTTP 418 received,", with: 418) ?? .init()
                            observer.onError(nsError)
                            return
                        case 423:
                            let nsError = self?.setupError("LOCKED: HTTP 423 received.", with: 423) ?? .init()
                            observer.onError(nsError)
                            return
                        default:
                            break
                        }
                        
                        Log.error("Network or response format error: \(error)")
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
                        Log.error("Network or response format error: \(error)")
                        observer.onError(error)
                    }
                }
            
            return Disposables.create {
                task?.cancel()
            }
        }
    }
    
    
    // MARK: Check version
    
    func checkClientVersion() -> Observable<String> {
        
        return Observable.create { [weak self] observer -> Disposable in
            
            let task = self?.session.request(AuthRequest.updateCheck)
                .validate(statusCode: 200..<500)
                .responseString { response in
                    switch response.result {
                    case let .success(value):
                        if let error = response.error {
                            observer.onError(error)
                        } else {
                            observer.onNext(value)
                            observer.onCompleted()
                        }
                    case let .failure(error):
                        Log.error("Network or response format error: \(error)")
                        observer.onError(error)
                    }
                }
            
            return Disposables.create {
                task?.cancel()
            }
        }
    }
}
