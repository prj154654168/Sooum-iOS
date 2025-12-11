//
//  FetchNoticeUseCase.swift
//  SOOUM
//
//  Created by 오현식 on 12/2/25.
//

import RxSwift

protocol FetchNoticeUseCase: AnyObject {
    
    func notices(
        lastId: String?,
        size: Int,
        requestType: NotificationRequest.RequestType
    ) -> Observable<[NoticeInfo]>
}
