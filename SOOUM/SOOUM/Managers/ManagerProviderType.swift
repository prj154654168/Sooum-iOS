//
//  ManagerProviderType.swift
//  SOOUM
//
//  Created by 오현식 on 1/14/25.
//

import Foundation


protocol ManagerProviderType: AnyObject {
    var authManager: AuthManagerDelegate { get }
    var pushManager: PushManagerDelegate { get }
    var networkManager: NetworkManagerDelegate { get }
    var locationManager: LocationManager { get }
}

final class ManagerProviderContainer: ManagerProviderType {
    lazy var authManager: AuthManagerDelegate = AuthManager(provider: self)
    lazy var pushManager: PushManagerDelegate = PushManager(provider: self)
    lazy var networkManager: NetworkManagerDelegate = NetworkManager(provider: self)
    lazy var locationManager: LocationManager = LocationManager(provider: self)
}

extension ManagerProviderType {
    
    func initialize() {
        _ = self.authManager
        _ = self.pushManager
        _ = self.networkManager
        _ = self.locationManager
    }
}
