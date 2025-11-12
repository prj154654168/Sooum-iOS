//
//  SimpleReachability.swift
//  SOOUM
//
//  Created by 오현식 on 11/13/25.
//

import Network

import RxCocoa
import RxSwift

final class SimpleReachability {
    
    enum Text {
        static let networkMoniterQueueLabel: String = "com.sooum.network.monitor.queue"
    }
    
    static let shared = SimpleReachability()
    
    private let monitor = NWPathMonitor()
    private let isConnect = BehaviorSubject<Bool>(value: true)
    
    lazy var isConnected: Observable<Bool> = {
        return self.isConnect
            .distinctUntilChanged()
            .asObservable()
            .share(replay: 1, scope: .forever)
    }()
    
    private init() {
        
        self.monitor.pathUpdateHandler = { [weak self] path in
            let isAvailable = path.status == .satisfied
            Log.info("Network is \(isAvailable ? "available" : "unavailable")")
            self?.isConnect.onNext(isAvailable)
        }
        self.monitor.start(queue: DispatchQueue(label: Text.networkMoniterQueueLabel))
    }
    
    deinit {
        self.monitor.cancel()
    }
}
