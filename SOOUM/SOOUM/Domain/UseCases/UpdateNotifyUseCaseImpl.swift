//
//  UpdateNotifyUseCaseImpl.swift
//  SOOUM
//
//  Created by 오현식 on 12/3/25.
//

import RxSwift

final class UpdateNotifyUseCaseImpl: UpdateNotifyUseCase {
    
    private let repository: SettingsRepository
    
    init(repository: SettingsRepository) {
        self.repository = repository
    }
    
    func notificationStatus() -> Bool {
        
        return self.repository.notificationStatus()
    }
    
    func switchNotification(on: Bool) -> Observable<Void> {
        
        return self.repository.switchNotification(on: on).map { _ in }
    }
    
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
    ) -> Observable<Bool> {
        
        return self.repository.updateNotify(
            commentCardNotify: commentCardNotify,
            cardLikeNotify: cardLikeNotify,
            followUserCardNotify: followUserCardNotify,
            newFollowerNotify: newFollowerNotify,
            cardNewCommentNotify: cardNewCommentNotify,
            recommendedContentNotify: recommendedContentNotify,
            favoriteTagNotify: favoriteTagNotify,
            serviceUpdateNotify: serviceUpdateNotify,
            policyViolationNotify: policyViolationNotify
        )
        .map { $0 == 200 }
    }
}
