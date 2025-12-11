//
//  LocationUseCase.swift
//  SOOUM
//
//  Created by 오현식 on 12/2/25.
//

import RxSwift

protocol LocationUseCase: AnyObject {
    
    func coordinate() -> Coordinate
    func hasPermission() -> Bool
    func requestLocationPermission()
    func checkLocationAuthStatus() -> AuthStatus
}
