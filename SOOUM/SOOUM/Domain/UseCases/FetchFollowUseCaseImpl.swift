//
//  FetchFollowUseCaseImpl.swift
//  SOOUM
//
//  Created by 오현식 on 12/3/25.
//

import RxSwift

final class FetchFollowUseCaseImpl: FetchFollowUseCase {
    
    private let repository: UserRepository
    
    init(repository: UserRepository) {
        self.repository = repository
    }
    
    func followers(userId: String, lastId: String?) -> Observable<[FollowInfo]> {
        
        return self.repository.followers(userId: userId, lastId: lastId).map(\.followInfos)
    }
    
    func followings(userId: String, lastId: String?) -> Observable<[FollowInfo]> {
        
        return self.repository.followings(userId: userId, lastId: lastId).map(\.followInfos)
    }
}
