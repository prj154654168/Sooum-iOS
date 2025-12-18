//
//  ValidateUserUseCaseImpl.swift
//  SOOUM
//
//  Created by 오현식 on 12/3/25.
//

import RxSwift

final class ValidateUserUseCaseImpl: ValidateUserUseCase {
    
    private let userRepository: UserRepository
    private let settingsRepository: SettingsRepository
    
    init(user: UserRepository, settings: SettingsRepository) {
        self.userRepository = user
        self.settingsRepository = settings
    }
    
    func checkValidation() -> Observable<CheckAvailable> {
        
        return self.userRepository.checkAvailable().map(\.checkAvailable)
    }
    
    func iswithdrawn() -> Observable<RejoinableDateInfo> {
        
        return self.settingsRepository.rejoinableDate().map(\.rejoinableDate)
    }
    
    func postingPermission() -> Observable<PostingPermission> {
        
        return self.userRepository.postingPermission().map(\.postingPermission)
    }
}
