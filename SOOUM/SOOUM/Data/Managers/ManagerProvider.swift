//
//  ManagerProvider.swift
//  SOOUM
//
//  Created by 오현식 on 1/14/25.
//

import Foundation


protocol ManagerProviderType: AnyObject {
    var authManager: AuthManagerDelegate { get }
    var pushManager: PushManagerDelegate { get }
    var networkManager: NetworkManagerDelegate { get }
    var locationManager: LocationManagerDelegate { get }
}

final class ManagerProviderContainer: ManagerProviderType {
    lazy var managerType: ManagerTypeDelegate = ManagerTypeContainer()
    
    var authManager: AuthManagerDelegate { self.managerType.authManager }
    var pushManager: PushManagerDelegate { self.managerType.pushManager }
    var networkManager: NetworkManagerDelegate { self.managerType.networkManager }
    var locationManager: LocationManagerDelegate { self.managerType.locationManager }
}
