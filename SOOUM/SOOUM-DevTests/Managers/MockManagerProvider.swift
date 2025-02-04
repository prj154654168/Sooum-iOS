//
//  MockManagerProvider.swift
//  SOOUM-DevTests
//
//  Created by 오현식 on 2/1/25.
//

@testable import SOOUM_Dev


final class MockManagerProviderContainer: ManagerProviderType {
    
    lazy var managerType: ManagerTypeDelegate = MockManagerProvider()
    
    var authManager: AuthManagerDelegate { self.managerType.authManager }
    var pushManager: PushManagerDelegate { self.managerType.pushManager }
    var networkManager: NetworkManagerDelegate { self.managerType.networkManager }
    var locationManager: LocationManagerDelegate { self.managerType.locationManager }
}

final class MockManagerProvider: ManagerTypeDelegate {
    
    lazy var authManager: AuthManagerDelegate = MockAuthManager(provider: self, configure: .init())
    lazy var pushManager: PushManagerDelegate = MockPushManager(provider: self, configure: .init())
    lazy var networkManager: NetworkManagerDelegate = MockNetworkManager(provider: self, configure: .init())
    lazy var locationManager: LocationManagerDelegate = MockLocationManager(provider: self, configure: .init())
}
