//
//  NotificationRemoteDataSource.swift
//  SOOUM
//
//  Created by 오현식 on 9/17/25.
//

import Foundation

import RxSwift

protocol NotificationRemoteDataSource {
    
    func unreadNotifications(lastId: String?) -> Observable<CompositeNotificationInfoResponse>
    func readNotifications(lastId: String?) -> Observable<CompositeNotificationInfoResponse>
    func requestRead(notificationId: String) -> Observable<Int>
    func notices(lastId: String?, size: Int?) -> Observable<NoticeInfoResponse>
}
