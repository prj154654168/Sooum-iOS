//
//  NotificationUseCaseImpl.swift
//  SOOUM
//
//  Created by 오현식 on 9/17/25.
//

import RxSwift

class NotificationUseCaseImpl: NotificationUseCase {
    
    private let repository: NotificationRepository
    
    init(repository: NotificationRepository) {
        self.repository = repository
    }
    
    func unreadNotifications(lastId: String?) -> Observable<[CompositeNotificationInfo]> {
        
        return self.repository.unreadNotifications(lastId: lastId).map(\.notificationInfo)
    }
    
    func readNotifications(lastId: String?) -> Observable<[CompositeNotificationInfo]> {
        
        return self.repository.readNotifications(lastId: lastId).map(\.notificationInfo)
    }
    
    func requestRead(notificationId: String) -> Observable<Bool> {
        
        return self.repository.requestRead(notificationId: notificationId).map { $0 == 200 }
    }
}
