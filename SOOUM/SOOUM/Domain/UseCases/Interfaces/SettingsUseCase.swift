//
//  SettingsUseCase.swift
//  SOOUM
//
//  Created by 오현식 on 11/9/25.
//

import Foundation

import RxSwift

protocol SettingsUseCase {
    
    func rejoinableDate() -> Observable<RejoinableDateInfo>
    func issue() -> Observable<TransferCodeInfo>
    func enter(code: String, encryptedDeviceId: String) -> Observable<Bool>
    func update() -> Observable<TransferCodeInfo>
    func blockUsers(lastId: String?) -> Observable<[BlockUserInfo]>
    
    func notificationStatus() -> Bool
    func switchNotification(on: Bool) -> Observable<Void>
    
    func coordinate() -> Coordinate
    func hasPermission() -> Bool
    func requestLocationPermission()
    func checkLocationAuthStatus() -> AuthStatus
}
