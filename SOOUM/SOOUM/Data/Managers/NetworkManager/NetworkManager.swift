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
    
    func request(request: BaseRequest) -> Observable<Int>
    func request<T: Decodable>(_ object: T.Type, request: BaseRequest) -> Observable<T>
    func upload(
        _ data: Data,
        to url: URLConvertible
    ) -> Observable<Result<Void, Error>>
    
    func fetch<T: Decodable>(_ object: T.Type, request: BaseRequest) -> Observable<T>
    func perform(_ request: BaseRequest) -> Observable<Int>
    func perform<T: Decodable>(_ object: T.Type, request: BaseRequest) -> Observable<T>

    func registerFCMToken(with tokenSet: PushTokenSet, _ function: String)
    func registerFCMToken(from function: String)
    
    func version() -> Observable<Result<AppVersionStatusResponse, Error>>
    func updateCheck() -> Observable<AppVersionStatusResponse>
}

class NetworkManager: CompositeManager<NetworkManagerConfiguration> {
    
    /// URLSession in Alamofire
    private let session: Session
    
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    
    override init(provider: ManagerTypeDelegate, configure: NetworkManagerConfiguration) {
        self.session = .init(
            configuration: configure.configuration.sessionConfiguration,
            interceptor: CompositeInterceptor(provider: provider),
            eventMonitors: [LogginMonitor()]
        )
        self.decoder = configure.configuration.decoder
        self.encoder = configure.configuration.encoder
        
        super.init(provider: provider, configure: configure)
    }
    
    private func setupError(with statusCode: Int) -> NSError? {
        guard (400..<500).contains(statusCode) else { return nil }
        
        let definedError = DefinedError.error(with: statusCode)
        return definedError.toNSError()
    }
}

extension NetworkManager: NetworkManagerDelegate {
    
    
    // MARK: Request network sevice
    
    func request(request: BaseRequest) -> Observable<Int> {
        return Observable.create { [weak self] observer -> Disposable in
            
            let task = self?.session.request(request)
                .validate(statusCode: 200..<300)
                .response { response in
                    let statusCode = response.response?.statusCode ?? 0
                    
                    switch response.result {
                    case .success:
                        if let nsError = self?.setupError(with: statusCode) {
                            Log.error(nsError.localizedDescription)
                            observer.onError(nsError)
                        } else {
                            observer.onNext(statusCode)
                            observer.onCompleted()
                        }
                    case let .failure(error):
                        if let nsError = self?.setupError(with: statusCode) {
                            Log.error(nsError.localizedDescription)
                            observer.onError(nsError)
                        } else {
                            Log.error("Network or response format error: with \(error.localizedDescription)")
                            observer.onError(error)
                        }
                    }
                }
            
            return Disposables.create {
                task?.cancel()
            }
        }
    }
    
    func request<T: Decodable>(_ object: T.Type, request: BaseRequest) -> Observable<T> {
        return Observable.create { [weak self] observer -> Disposable in
            
            let task = self?.session.request(request)
                .validate(statusCode: 200..<500)
                .responseDecodable(
                    of: object,
                    decoder: self?.decoder ?? JSONDecoder(),
                    emptyResponseCodes: [200, 201, 204, 205]
                ) { response in
                    let statusCode = response.response?.statusCode ?? 0
                    
                    switch response.result {
                    case let .success(value):
                        if let nsError = self?.setupError(with: statusCode) {
                            Log.error(nsError.localizedDescription)
                            observer.onError(nsError)
                        } else {
                            observer.onNext(value)
                            observer.onCompleted()
                        }
                    case let .failure(error):
                        if let nsError = self?.setupError(with: statusCode) {
                            Log.error(nsError.localizedDescription)
                            observer.onError(nsError)
                        } else {
                            Log.error("Network or response format error: with \(error.localizedDescription)")
                            observer.onError(error)
                        }
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
                        observer.onNext(.success(()))
                        observer.onCompleted()
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
    
    func fetch<T: Decodable>(_ object: T.Type, request: BaseRequest) -> Observable<T> {
        
        guard request.method == .get else {
            return Observable.error(DefinedError.invalidMethod(request.method))
        }
        
        return self.request(object, request: request)
    }
    
    func perform(_ request: BaseRequest) -> Observable<Int> {
        
        guard request.method == .post || request.method == .patch || request.method == .delete else {
            return Observable.error(DefinedError.invalidMethod(request.method))
        }
        
        return self.request(request: request)
    }
    
    func perform<T: Decodable>(_ object: T.Type, request: BaseRequest) -> Observable<T> {
        
        guard request.method == .post || request.method == .patch || request.method == .delete else {
            return Observable.error(DefinedError.invalidMethod(request.method))
        }
        
        return self.request(object, request: request)
    }
}
