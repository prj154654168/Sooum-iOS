//
//  FetchBlockUserUseCaseImpl.swift
//  SOOUM
//
//  Created by 오현식 on 12/3/25.
//

import RxSwift

final class FetchBlockUserUseCaseImpl: FetchBlockUserUseCase {
    
    private let repository: SettingsRepository
    
    init(repository: SettingsRepository) {
        self.repository = repository
    }
    
    func blockUsers(lastId: String?) -> Observable<[BlockUserInfo]> {
        
        return self.repository.blockUsers(lastId: lastId).map(\.blockUsers)
    }
}
