//
//  AppAssembler.swift
//  SOOUM
//
//  Created by 오현식 on 9/17/25.
//

import Foundation

final class AppAssembler: BaseAssemblerable {
    
    // TODO: 임시, 추후 Coordinator 및 VIPER 적용 시 분기
    func assemble(container: BaseDIContainerable) {
        
        
        // MARK: Services
        
        container.register(ManagerProviderType.self, factory: { _ in ManagerProviderContainer() })
        
        
        // MARK: AppVersionRepository
        
        container.register(AppVersionRemoteDataSource.self, factory: { resolver in
            AppVersionRemoteDataSourceImpl(provider: resolver.resolve(ManagerProviderType.self))
        })
        container.register(AppVersionRepository.self, factory: { resolver in
            AppVersionRepositoryImpl(remoteDataSource: resolver.resolve(AppVersionRemoteDataSource.self))
        })
        
        
        // MARK: AuthRepository
        
        container.register(AuthRemoteDataSource.self, factory: { resolver in
            AuthRemoteDataSourceImpl(provider: resolver.resolve(ManagerProviderType.self))
        })
        container.register(AuthLocalDataSource.self, factory: { resolver in
            AuthLocalDataSourceImpl(provider: resolver.resolve(ManagerProviderType.self))
        })
        
        container.register(AuthRepository.self, factory: { resolver in
            AuthRepositoryImpl(
                remoteDataSource: resolver.resolve(AuthRemoteDataSource.self),
                localDataSource: resolver.resolve(AuthLocalDataSource.self)
            )
        })
        
        
        // MARK: UserRepository
        
        container.register(UserRemoteDataSource.self, factory: { resolver in
            UserRemoteDataSourceImpl(provider: resolver.resolve(ManagerProviderType.self))
        })
        
        container.register(UserRepository.self, factory: { resolver in
            UserRepositoryImpl(remoteDataSource: resolver.resolve(UserRemoteDataSource.self))
        })
        
        
        // MARK: NotificationRepository
        
        container.register(NotificationRemoteDataSource.self, factory: { resolver in
            NotificationRemoteDataSoruceImpl(provider: resolver.resolve(ManagerProviderType.self))
        })
        
        container.register(NotificationRepository.self, factory: { resolver in
            NotificationRepositoryImpl(remoteDataSource: resolver.resolve(NotificationRemoteDataSource.self))
        })
        
        
        // MARK: CardRepository
        
        container.register(CardRemoteDataSource.self, factory: { resolver in
            CardRemoteDataSourceImpl(provider: resolver.resolve(ManagerProviderType.self))
        })
        
        container.register(CardRepository.self, factory: { resolver in
            CardRepositoryImpl(remoteDataSource: resolver.resolve(CardRemoteDataSource.self))
        })
        
        
        // MARK: TagRepository
        
        container.register(TagRemoteDataSource.self, factory: { resolver in
            TagRemoteDataSourceImpl(provider: resolver.resolve(ManagerProviderType.self))
        })
        
        container.register(TagRepository.self, factory: { resolver in
            TagRepositoryImpl(remoteDataSource: resolver.resolve(TagRemoteDataSource.self))
        })
        
        
        // MARK: SettingsRepository
        
        container.register(SettingsRemoteDataSource.self, factory: { resolver in
            SettingsRemoteDataSourceImpl(provider: resolver.resolve(ManagerProviderType.self))
        })
        container.register(SettingsLocalDataSource.self, factory: { resolver in
            SettingsLocalDataSourceImpl(provider: resolver.resolve(ManagerProviderType.self))
        })
        
        container.register(SettingsRepository.self, factory: { resolver in
            SettingsRepositoryImpl(
                remoteDataSource: resolver.resolve(SettingsRemoteDataSource.self),
                localDataSource: resolver.resolve(SettingsLocalDataSource.self)
            )
        })
        
        
        // MARK: AppVersionUseCase
        
        container.register(AppVersionUseCase.self, factory: { resolver in
            AppVersionUseCaseImpl(repository: resolver.resolve(AppVersionRepository.self))
        })
        
        
        // MARK: AuthUseCase
        
        container.register(AuthUseCase.self, factory: { resolver in
            AuthUseCaseImpl(repository: resolver.resolve(AuthRepository.self))
        })
        
        
        // MARK: BlockUserUseCase
        
        container.register(BlockUserUseCase.self, factory: { resolver in
            BlockUserUseCaseImpl(repository: resolver.resolve(UserRepository.self))
        })
        
        
        // MARK: CardImageUseCase
        
        container.register(CardImageUseCase.self, factory: { resolver in
            CardImageUseCaseImpl(repository: resolver.resolve(CardRepository.self))
        })
        
        
        // MARK: DeleteCardUseCase
        
        container.register(DeleteCardUseCase.self, factory: { resolver in
            DeleteCardUseCaseImpl(repository: resolver.resolve(CardRepository.self))
        })
        
        
        // MARK: FetchBlockUserUseCase
        
        container.register(FetchBlockUserUseCase.self, factory: { resolver in
            FetchBlockUserUseCaseImpl(repository: resolver.resolve(SettingsRepository.self))
        })
        
        
        // MARK: FetchCardDetailUseCase
        
        container.register(FetchCardDetailUseCase.self, factory: { resolver in
            FetchCardDetailUseCaseImpl(repository: resolver.resolve(CardRepository.self))
        })
        
        
        // MARK: FetchCardUseCase
        
        container.register(FetchCardUseCase.self, factory: { resolver in
            FetchCardUseCaseImpl(repository: resolver.resolve(CardRepository.self))
        })
        
        
        // MARK: FetchFollowUseCase
        
        container.register(FetchFollowUseCase.self, factory: { resolver in
            FetchFollowUseCaseImpl(repository: resolver.resolve(UserRepository.self))
        })
        
        
        // MARK: FetchNoticeUseCase
        
        container.register(FetchNoticeUseCase.self, factory: { resolver in
            FetchNoticeUseCaseImpl(repository: resolver.resolve(NotificationRepository.self))
        })
        
        
        // MARK: FetchTagUseCase
        
        container.register(FetchTagUseCase.self, factory: { resolver in
            FetchTagUseCaseImpl(repository: resolver.resolve(TagRepository.self))
        })
        
        
        // MARK: FetchUserInfoUseCase
        
        container.register(FetchUserInfoUseCase.self, factory: { resolver in
            FetchUserInfoUseCaseImpl(repository: resolver.resolve(UserRepository.self))
        })
        
        
        // MARK: LocationUseCase
        
        container.register(LocationUseCase.self, factory: { resolver in
            LocationUseCaseImpl(repository: resolver.resolve(SettingsRepository.self))
        })
        
        
        // MARK: NotificationUseCase
        
        container.register(NotificationUseCase.self, factory: { resolver in
            NotificationUseCaseImpl(repository: resolver.resolve(NotificationRepository.self))
        })
        
        
        // MARK: ReportCardUseCase
        
        container.register(ReportCardUseCase.self, factory: { resolver in
            ReportCardUseCaseImpl(repository: resolver.resolve(CardRepository.self))
        })
        
        
        // MARK: TransferAccountUseCase
        
        container.register(TransferAccountUseCase.self, factory: { resolver in
            TransferAccountUseCaseImpl(repository: resolver.resolve(SettingsRepository.self))
        })
        
        
        // MARK: UpdateCardLikeUseCase
        
        container.register(UpdateCardLikeUseCase.self, factory: { resolver in
            UpdateCardLikeUseCaseImpl(repository: resolver.resolve(CardRepository.self))
        })
        
        
        // MARK: UpdateFollowUseCase
        
        container.register(UpdateFollowUseCase.self, factory: { resolver in
            UpdateFollowUseCaseImpl(repository: resolver.resolve(UserRepository.self))
        })
        
        
        // MARK: UpdateNotifyUseCase
        
        container.register(UpdateNotifyUseCase.self, factory: { resolver in
            UpdateNotifyUseCaseImpl(repository: resolver.resolve(SettingsRepository.self))
        })
        
        
        // MARK: UpdateTagFavoriteUseCase
        
        container.register(UpdateTagFavoriteUseCase.self, factory: { resolver in
            UpdateTagFavoriteUseCaseImpl(repository: resolver.resolve(TagRepository.self))
        })
        
        
        // MARK: UpdateUserInfoUseCases
        
        container.register(UpdateUserInfoUseCase.self, factory: { resolver in
            UpdateUserInfoUseCaseImpl(repository: resolver.resolve(UserRepository.self))
        })
        
        
        // MARK: UploadUserImageUseCase
        
        container.register(UploadUserImageUseCase.self, factory: { resolver in
            UploadUserImageUseCaseImpl(repository: resolver.resolve(UserRepository.self))
        })
        
        
        // MARK: ValidateNicknameUseCase
        
        container.register(ValidateNicknameUseCase.self, factory: { resolver in
            ValidateNicknameUseCaseImpl(repository: resolver.resolve(UserRepository.self))
        })
        
        
        // MARK: ValidateUserUseCase
        
        container.register(ValidateUserUseCase.self, factory: { resolver in
            ValidateUserUseCaseImpl(
                user: resolver.resolve(UserRepository.self),
                settings: resolver.resolve(SettingsRepository.self)
            )
        })
        
        
        // MARK: WriteCardUseCase
        
        container.register(WriteCardUseCase.self, factory: { resolver in
            WriteCardUseCaseImpl(repository: resolver.resolve(CardRepository.self))
        })
    }
}
