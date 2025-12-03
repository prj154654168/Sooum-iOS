//
//  NotificationUseCase.swift
//  SOOUM
//
//  Created by 오현식 on 9/17/25.
//

import RxSwift

protocol NotificationUseCase: AnyObject {
    
    func unreadNotifications(lastId: String?) -> Observable<[CompositeNotificationInfo]>
    func readNotifications(lastId: String?) -> Observable<[CompositeNotificationInfo]>
    func requestRead(notificationId: String) -> Observable<Bool>
}
