//
//  FetchNoticeUseCaseImpl.swift
//  SOOUM
//
//  Created by 오현식 on 12/3/25.
//

import RxSwift

final class FetchNoticeUseCaseImpl: FetchNoticeUseCase {
    
    private let repository: NotificationRepository
    
    init(repository: NotificationRepository) {
        self.repository = repository
    }
    
    func notices(
        lastId: String?,
        size: Int,
        requestType: NotificationRequest.RequestType
    ) -> Observable<[NoticeInfo]> {
        
        return self.repository.notices(
            lastId: lastId,
            size: size,
            requestType: requestType
        )
        .map(\.noticeInfos)
    }
}
