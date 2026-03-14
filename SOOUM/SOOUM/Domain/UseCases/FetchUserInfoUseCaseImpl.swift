//
//  FetchUserInfoUseCaseImpl.swift
//  SOOUM
//
//  Created by 오현식 on 12/3/25.
//

import RxSwift

final class FetchUserInfoUseCaseImpl: FetchUserInfoUseCase {
    
    private let userRepository: UserRepository
    private let settingsRepository: SettingsRepository
    
    init(userRepository: UserRepository, settingsRepository: SettingsRepository) {
        self.userRepository = userRepository
        self.settingsRepository = settingsRepository
    }
    
    func myRole() -> Observable<UserRole> {
        
        return self.userRepository.role().map(\.role)
    }
    
    func userInfo(userId: String?) -> Observable<ProfileInfo> {
        
        return self.userRepository.profile(userId: userId).map(\.profileInfo)
    }
    
    func myNickname() -> Observable<String> {
        
        return self.userInfo(userId: nil).map(\.nickname)
    }
    
    func notify() -> Observable<PushNotiStatusInfo> {
        
        return self.settingsRepository.notify().map(\.pushNotiStatusInfo)
    }
}
