//
//  NotificationRemoteDataSoruceImpl.swift
//  SOOUM
//
//  Created by 오현식 on 9/17/25.
//

import Foundation

import RxSwift

class NotificationRemoteDataSoruceImpl: NotificationRemoteDataSource {
    
    private let provider: ManagerProviderType
    
    init(provider: ManagerProviderType) {
        self.provider = provider
    }
    
    func unreadNotifications(lastId: String?) -> Observable<[NotificationInfoResponse]> {
        
        let request: NotificationRequest = .unreadNotifications(lastId: lastId)
        return self.provider.networkManager.fetch([NotificationInfoResponse].self, request: request)
    }
    
    func unreadCardNotifications(lastId: String?) -> Observable<[NotificationInfoResponse]> {
        
        let request: NotificationRequest = .unreadCardNotifications(lastId: lastId)
        return self.provider.networkManager.fetch([NotificationInfoResponse].self, request: request)
    }
    
    func unreadFollowNotifications(lastId: String?) -> Observable<[NotificationInfoResponse]> {
        
        let request: NotificationRequest = .unreadFollowNotifications(lastId: lastId)
        return self.provider.networkManager.fetch([NotificationInfoResponse].self, request: request)
    }
    
    func unreadNoticeNoticeNotifications(lastId: String?) -> Observable<[NotificationInfoResponse]> {
        
        let request: NotificationRequest = .unreadNoticeNoticeNotifications(lastId: lastId)
        return self.provider.networkManager.fetch([NotificationInfoResponse].self, request: request)
    }
    
    func readNotifications(lastId: String?) -> Observable<[NotificationInfoResponse]> {
        
        let request: NotificationRequest = .readNotifications(lastId: lastId)
        return self.provider.networkManager.fetch([NotificationInfoResponse].self, request: request)
    }
    
    func readCardNotifications(lastId: String?) -> Observable<[NotificationInfoResponse]> {
        
        let request: NotificationRequest = .readCardNotifications(lastId: lastId)
        return self.provider.networkManager.fetch([NotificationInfoResponse].self, request: request)
    }
    
    func readFollowNotifications(lastId: String?) -> Observable<[NotificationInfoResponse]> {
        
        let request: NotificationRequest = .readFollowNotifications(lastId: lastId)
        return self.provider.networkManager.fetch([NotificationInfoResponse].self, request: request)
    }
    
    func readNoticeNoticeNotifications(lastId: String?) -> Observable<[NotificationInfoResponse]> {
        
        let request: NotificationRequest = .readNoticeNoticeNotifications(lastId: lastId)
        return self.provider.networkManager.fetch([NotificationInfoResponse].self, request: request)
    }
    
    func requestRead(notificationId: String) -> Observable<Int> {
        
        let request: NotificationRequest = .requestRead(notificationId: notificationId)
        return self.provider.networkManager.perform(Int.self, request: request)
    }
}
