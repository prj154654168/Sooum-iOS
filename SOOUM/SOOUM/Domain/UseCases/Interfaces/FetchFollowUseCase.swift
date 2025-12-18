//
//  FetchFollowUseCase.swift
//  SOOUM
//
//  Created by 오현식 on 12/2/25.
//

import RxSwift

protocol FetchFollowUseCase: AnyObject {
    
    func followers(userId: String, lastId: String?) -> Observable<[FollowInfo]>
    func followings(userId: String, lastId: String?) -> Observable<[FollowInfo]>
}
