//
//  NotificationUseCase.swift
//  SOOUM
//
//  Created by 오현식 on 9/17/25.
//

import Foundation

import RxSwift

protocol NotificationUseCase {
    
    func unreadNotifications(lastId: String?) -> Observable<[CompositeNotificationInfo]>
    func readNotifications(lastId: String?) -> Observable<[CompositeNotificationInfo]>
    func requestRead(notificationId: String) -> Observable<Bool>
    func notices(lastId: String?) -> Observable<[NoticeInfo]>
}
