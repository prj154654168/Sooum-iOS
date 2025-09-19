//
//  UserUseCase.swift
//  SOOUM
//
//  Created by 오현식 on 9/17/25.
//

import Foundation

import RxSwift

protocol UserUseCase {
    
    func isAvailableCheck() -> Observable<CheckAvailable>
    func nickname() -> Observable<String>
    func isNicknameValid(nickname: String) -> Observable<Bool>
    func updateNickname(nickname: String) -> Observable<Bool>
    func presignedURL() -> Observable<ImageUrlInfo>
    func uploadImage(_ data: Data, with url: URL) -> Observable<Bool>
    func updateImage(imageName: String) -> Observable<Bool>
    func updateFCMToken(fcmToken: String) -> Observable<Bool>
}
