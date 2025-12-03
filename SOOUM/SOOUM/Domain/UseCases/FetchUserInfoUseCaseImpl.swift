//
//  FetchUserInfoUseCaseImpl.swift
//  SOOUM
//
//  Created by 오현식 on 12/3/25.
//

import RxSwift

final class FetchUserInfoUseCaseImpl: FetchUserInfoUseCase {
    
    private let repository: UserRepository
    
    init(repository: UserRepository) {
        self.repository = repository
    }
    
    func userInfo(userId: String?) -> Observable<ProfileInfo> {
        
        return self.repository.profile(userId: userId).map(\.profileInfo)
    }
    
    func myNickname() -> Observable<String> {
        
        return self.repository.profile(userId: nil).map { $0.profileInfo.nickname }
    }
}
