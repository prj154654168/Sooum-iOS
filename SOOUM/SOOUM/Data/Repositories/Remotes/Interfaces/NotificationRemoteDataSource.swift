//
//  NotificationRemoteDataSource.swift
//  SOOUM
//
//  Created by 오현식 on 9/17/25.
//

import Foundation

import RxSwift

protocol NotificationRemoteDataSource {
    
    func unreadNotifications(lastId: String?) -> Observable<[NotificationInfoResponse]>
    func unreadCardNotifications(lastId: String?) -> Observable<[NotificationInfoResponse]>
    func unreadFollowNotifications(lastId: String?) -> Observable<[NotificationInfoResponse]>
    func unreadNoticeNoticeNotifications(lastId: String?) -> Observable<[NotificationInfoResponse]>
    func readNotifications(lastId: String?) -> Observable<[NotificationInfoResponse]>
    func readCardNotifications(lastId: String?) -> Observable<[NotificationInfoResponse]>
    func readFollowNotifications(lastId: String?) -> Observable<[NotificationInfoResponse]>
    func readNoticeNoticeNotifications(lastId: String?) -> Observable<[NotificationInfoResponse]>
    func requestRead(notificationId: String) -> Observable<Int>
}
