//
//  SettingsUserCase.swift
//  SOOUM
//
//  Created by 오현식 on 11/9/25.
//

import Foundation

import RxSwift

protocol SettingsUserCase {
    
    func rejoinableDate() -> Observable<RejoinableDateInfo>
    func issue() -> Observable<TransferCodeInfo>
    func enter(code: String, encryptedDeviceId: String) -> Observable<Bool>
    func update() -> Observable<TransferCodeInfo>
    func blockUsers(lastId: String?) -> Observable<[BlockUserInfo]>
}
