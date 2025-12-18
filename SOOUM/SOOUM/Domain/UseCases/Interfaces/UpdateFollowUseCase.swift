//
//  UpdateFollowUseCase.swift
//  SOOUM
//
//  Created by 오현식 on 12/2/25.
//

import RxSwift

protocol UpdateFollowUseCase: AnyObject {
    
    func updateFollowing(userId: String, isFollow: Bool) -> Observable<Bool>
}
