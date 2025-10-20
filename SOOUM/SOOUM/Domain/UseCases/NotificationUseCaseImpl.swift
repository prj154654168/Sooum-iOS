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
    
    func unreadNotifications(lastId: String?) -> Observable<[CompositeNotificationInfo]> {
        
        return self.repository.unreadNotifications(lastId: lastId).map { $0.notificationInfo }
    }
    
    func readNotifications(lastId: String?) -> Observable<[CompositeNotificationInfo]> {
        
        return self.repository.readNotifications(lastId: lastId).map { $0.notificationInfo }
    }
    
    func requestRead(notificationId: String) -> Observable<Bool> {
        
        return self.repository.requestRead(notificationId: notificationId).map { $0 == 200 }
    }
    
    func notices(lastId: String?, size: Int?) -> Observable<[NoticeInfo]> {
        
        return self.repository.notices(lastId: lastId, size: size).map { $0.noticeInfos }
    }
}
