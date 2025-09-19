//
//  NotificationUseCaseImpl.swift
//  SOOUM
//
//  Created by 오현식 on 9/17/25.
//

import Foundation

import RxSwift

class NotificationUseCaseImpl: NotificationUseCase {
    
    private let repository: NotificationRepository
    
    init(repository: NotificationRepository) {
        self.repository = repository
    }
    
    func unreadNotifications(lastId: String?) -> Observable<[NotificationInfoResponse]> {
        
        return self.repository.unreadNotifications(lastId: lastId)
    }
    
    func unreadCardNotifications(lastId: String?) -> Observable<[NotificationInfoResponse]> {
        
        return self.repository.unreadCardNotifications(lastId: lastId)
    }
    
    func unreadFollowNotifications(lastId: String?) -> Observable<[NotificationInfoResponse]> {
        
        return self.repository.unreadFollowNotifications(lastId: lastId)
    }
    
    func unreadNoticeNoticeNotifications(lastId: String?) -> Observable<[NotificationInfoResponse]> {
        
        return self.repository.unreadNoticeNoticeNotifications(lastId: lastId)
    }
    
    func readNotifications(lastId: String?) -> Observable<[NotificationInfoResponse]> {
        
        return self.repository.readNotifications(lastId: lastId)
    }
    
    func readCardNotifications(lastId: String?) -> Observable<[NotificationInfoResponse]> {
        
        return self.repository.readCardNotifications(lastId: lastId)
    }
    
    func readFollowNotifications(lastId: String?) -> Observable<[NotificationInfoResponse]> {
        
        return self.repository.readFollowNotifications(lastId: lastId)
    }
    
    func readNoticeNoticeNotifications(lastId: String?) -> Observable<[NotificationInfoResponse]> {
        
        return self.repository.readNoticeNoticeNotifications(lastId: lastId)
    }
    
    func requestRead(notificationId: String) -> Observable<Bool> {
        
        return self.repository.requestRead(notificationId: notificationId).map { $0 == 200 }
    }
}
