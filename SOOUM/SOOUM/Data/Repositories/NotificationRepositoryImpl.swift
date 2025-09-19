//
//  NotificationRepositoryImpl.swift
//  SOOUM
//
//  Created by 오현식 on 9/17/25.
//

import Foundation

import RxSwift

class NotificationRepositoryImpl: NotificationRepository {
    
    private let remoteDataSource: NotificationRemoteDataSource
    
    init(remoteDataSource: NotificationRemoteDataSource) {
        self.remoteDataSource = remoteDataSource
    }
    
    func unreadNotifications(lastId: String?) -> Observable<[NotificationInfoResponse]> {
        
        return self.remoteDataSource.unreadNotifications(lastId: lastId)
    }
    
    func unreadCardNotifications(lastId: String?) -> Observable<[NotificationInfoResponse]> {
        
        return self.remoteDataSource.unreadCardNotifications(lastId: lastId)
    }
    
    func unreadFollowNotifications(lastId: String?) -> Observable<[NotificationInfoResponse]> {
        
        return self.remoteDataSource.unreadFollowNotifications(lastId: lastId)
    }
    
    func unreadNoticeNoticeNotifications(lastId: String?) -> Observable<[NotificationInfoResponse]> {
        
        return self.remoteDataSource.unreadNoticeNoticeNotifications(lastId: lastId)
    }
    
    func readNotifications(lastId: String?) -> Observable<[NotificationInfoResponse]> {
        
        return self.remoteDataSource.readNotifications(lastId: lastId)
    }
    
    func readCardNotifications(lastId: String?) -> Observable<[NotificationInfoResponse]> {
        
        return self.remoteDataSource.readCardNotifications(lastId: lastId)
    }
    
    func readFollowNotifications(lastId: String?) -> Observable<[NotificationInfoResponse]> {
        
        return self.remoteDataSource.readFollowNotifications(lastId: lastId)
    }
    
    func readNoticeNoticeNotifications(lastId: String?) -> Observable<[NotificationInfoResponse]> {
        
        return self.remoteDataSource.readNoticeNoticeNotifications(lastId: lastId)
    }
    
    func requestRead(notificationId: String) -> Observable<Int> {
        
        return self.remoteDataSource.requestRead(notificationId: notificationId)
    }
}
