//
//  SettingsLocalDataSource.swift
//  SOOUM
//
//  Created by 오현식 on 11/17/25.
//

import RxSwift

protocol SettingsLocalDataSource {
    
    func notificationStatus() -> Bool
    func switchNotification(on: Bool) -> Observable<Error?>
    
    func coordinate() -> Coordinate
    func hasPermission() -> Bool
    func requestLocationPermission()
    func checkLocationAuthStatus() -> AuthStatus
}
