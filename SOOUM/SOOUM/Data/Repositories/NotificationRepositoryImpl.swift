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
    
    func unreadNotifications(lastId: String?) -> Observable<CompositeNotificationInfoResponse> {
        
        return self.remoteDataSource.unreadNotifications(lastId: lastId)
    }
    
    func readNotifications(lastId: String?) -> Observable<CompositeNotificationInfoResponse> {
        
        return self.remoteDataSource.readNotifications(lastId: lastId)
    }
    
    func requestRead(notificationId: String) -> Observable<Int> {
        
        return self.remoteDataSource.requestRead(notificationId: notificationId)
    }
    
    func notices(lastId: String?) -> Observable<NoticeInfoResponse> {
        
        return self.remoteDataSource.notices(lastId: lastId)
    }
}
