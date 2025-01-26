//
//  ManagerType.swift
//  SOOUM
//
//  Created by 오현식 on 1/26/25.
//

import Foundation

protocol ManagerTypeDelegate: AnyObject {
    var authManager: AuthManagerDelegate { get }
    var pushManager: PushManagerDelegate { get }
    var networkManager: NetworkManagerDelegate { get }
    var locationManager: LocationManagerDelegate { get }
}

final class ManagerTypeContainer: ManagerTypeDelegate {
    
    struct Configuration {
        
        var auth: AuthManagerConfiguration
        var push: PushManagerConfiguration
        var network: NetworkManagerConfiguration
        var location: LocationManagerConfigruation
        
        init(
            auth: AuthManagerConfiguration = .init(),
            push: PushManagerConfiguration = .init(),
            network: NetworkManagerConfiguration = .init(),
            location: LocationManagerConfigruation = .init()
        ) {
            self.auth = auth
            self.push = push
            self.network = network
            self.location = location
        }
    }
    
    lazy var authManager: AuthManagerDelegate = AuthManager(provider: self, configure: self.configuare.auth)
    lazy var pushManager: PushManagerDelegate = PushManager(provider: self, configure: self.configuare.push)
    lazy var networkManager: NetworkManagerDelegate = NetworkManager(provider: self, configure: self.configuare.network)
    lazy var locationManager: LocationManagerDelegate = LocationManager(provider: self, configure: self.configuare.location)
    
    let configuare: Configuration
    init() {
        self.configuare = .init()
    }
}
