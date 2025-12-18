//
//  UpdateNotifyUseCase.swift
//  SOOUM
//
//  Created by 오현식 on 12/2/25.
//

import RxSwift

protocol UpdateNotifyUseCase: AnyObject {
    
    func notificationStatus() -> Bool
    func switchNotification(on: Bool) -> Observable<Void>
    
    func updateNotify(isAllowNotify: Bool) -> Observable<Bool>
}
