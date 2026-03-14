//
//  SettingsRemoteDataSource.swift
//  SOOUM
//
//  Created by 오현식 on 11/9/25.
//

import Foundation

import RxSwift

protocol SettingsRemoteDataSource {
    
    func rejoinableDate() -> Observable<RejoinableDateInfoResponse>
    func issue() -> Observable<TransferCodeInfoResponse>
    func enter(code: String, encryptedDeviceId: String) -> Observable<Int>
    func update() -> Observable<TransferCodeInfoResponse>
    func blockUsers(lastId: String?) -> Observable<BlockUsersInfoResponse>
    func notify() -> Observable<PushNotiStatusInfoResponse>
    func updateNotify(
        commentCardNotify: Bool,
        cardLikeNotify: Bool,
        followUserCardNotify: Bool,
        newFollowerNotify: Bool,
        cardNewCommentNotify: Bool,
        recommendedContentNotify: Bool,
        favoriteTagNotify: Bool,
        serviceUpdateNotify: Bool,
        policyViolationNotify: Bool
    ) -> Observable<Int>
}
