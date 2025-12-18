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
    
    func unreadNotifications(lastId: String?) -> Observable<CompositeNotificationInfoResponse> {
        
        let request: NotificationRequest = .unreadNotifications(lastId: lastId)
        return self.provider.networkManager.fetch(CompositeNotificationInfoResponse.self, request: request)
    }
    
    func readNotifications(lastId: String?) -> Observable<CompositeNotificationInfoResponse> {
        
        let request: NotificationRequest = .readNotifications(lastId: lastId)
        return self.provider.networkManager.fetch(CompositeNotificationInfoResponse.self, request: request)
    }
    
    func requestRead(notificationId: String) -> Observable<Int> {
        
        let request: NotificationRequest = .requestRead(notificationId: notificationId)
        return self.provider.networkManager.perform(request)
    }
    
    func notices(lastId: String?, size: Int?, requestType: NotificationRequest.RequestType) -> Observable<NoticeInfoResponse> {
        
        let request: NotificationRequest = .notices(lastId: lastId, size: size, requestType: requestType)
        return self.provider.networkManager.fetch(NoticeInfoResponse.self, request: request)
    }
}
