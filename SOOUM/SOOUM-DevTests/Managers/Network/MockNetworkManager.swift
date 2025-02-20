//
//  MockNetworkManager.swift
//  SOOUM-DevTests
//
//  Created by 오현식 on 2/3/25.
//

@testable import SOOUM_Dev

import Alamofire
import RxSwift


class MockNetworkManager: CompositeManager<NetworkManagerConfiguration>, NetworkManagerDelegate {
    
    let mockSession: MockSession
    
    var disposeBag = DisposeBag()
    
    override init(provider: ManagerTypeDelegate, configure: NetworkManagerConfiguration) {
        self.mockSession = MockSession()
        
        super.init(provider: provider, configure: configure)
    }
    
    func request<T>(_ object: T.Type, request: any BaseRequest) -> Observable<T> where T : Decodable {
        return Observable.create { [weak self] observer -> Disposable in
            
            self?.mockSession.requestCalled = true
            
            if let error = self?.mockSession.mockError {
                observer.onError(error)
            }
            
            if let data = self?.mockSession.mockData {
                do {
                    let response = try JSONDecoder().decode(T.self, from: data)
                    observer.onNext(response)
                    observer.onCompleted()
                } catch {
                    observer.onError(error)
                }
            }
            
            return Disposables.create()
        }
    }
    
    func upload(_ data: Data, to url: URLConvertible) -> Observable<Result<Void, Error>> {
        return Observable.create { [weak self] observer -> Disposable in
            
            self?.mockSession.uploadCalled = true
            
            if let error = self?.mockSession.mockError {
                observer.onNext(.failure(error))
            } else {
                observer.onNext(.success(()))
            }
            
            observer.onCompleted()
            return Disposables.create()
        }
    }
    
    func checkClientVersion() -> Observable<String> { return Observable.just("1.0.0") }
    
    func registerFCMToken(with tokenSet: PushTokenSet, _ function: String) { }
    
    func registerFCMToken(from function: String) { }
}
