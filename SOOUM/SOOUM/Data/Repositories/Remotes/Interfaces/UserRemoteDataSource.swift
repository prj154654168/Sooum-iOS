//
//  UserRemoteDataSource.swift
//  SOOUM
//
//  Created by 오현식 on 9/17/25.
//

import Foundation

import RxSwift

protocol UserRemoteDataSource {
    
    func checkAvailable() -> Observable<CheckAvailableResponse>
    func nickname() -> Observable<NicknameResponse>
    func validateNickname(nickname: String) -> Observable<NicknameValidateResponse>
    func updateNickname(nickname: String) -> Observable<Int>
    func presignedURL() -> Observable<ImageUrlInfoResponse>
    func uploadImage(_ data: Data, with url: URL) -> Observable<Result<Void, Error>>
    func updateImage(imageName: String) -> Observable<Int>
    func updateFCMToken(fcmToken: String) -> Observable<Int>
}
