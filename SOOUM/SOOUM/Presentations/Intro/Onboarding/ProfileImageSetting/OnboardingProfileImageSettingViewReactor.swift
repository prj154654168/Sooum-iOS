//
//  OnboardingProfileImageSettingViewReactor.swift
//  SOOUM
//
//  Created by JDeoks on 11/12/24.
//

import ReactorKit

import Alamofire


class OnboardingProfileImageSettingViewReactor: Reactor {
    
    enum Action {
        case updateImage(UIImage)
        case updateProfile
    }
    
    enum Mutation {
        case updateImage(UIImage)
        case updateIsSuccess(Bool)
        case updateIsLoading(Bool)
    }
    
    struct State {
        var profileImage: UIImage?
        var isSuccess: Bool
        var isLoading: Bool
    }
    
    var nickname: String
    var imageName: String?
    
    var initialState: State = .init(
        profileImage: nil,
        isSuccess: false,
        isLoading: false
    )
    
    let provider: ManagerProviderType
    
    init(provider: ManagerProviderType, nickname: String) {
        self.provider = provider
        self.nickname = nickname
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .updateImage(image):
            return .concat([
                .just(.updateIsLoading(true)),
                self.updateImage(image),
                .just(.updateIsLoading(false))
            ])
            
        case .updateProfile:
            let trimedNickname = self.nickname.trimmingCharacters(in: .whitespacesAndNewlines)
            let request: JoinRequest = .registerUser(userName: trimedNickname, imageName: self.imageName)
            
            return self.provider.networkManager.request(Empty.self, request: request)
                .flatMapLatest { _ -> Observable<Mutation> in
                    return .just(.updateIsSuccess(true))
                }
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case let .updateImage(profileImage):
            newState.profileImage = profileImage
        case let .updateIsSuccess(isSuccess):
            newState.isSuccess = isSuccess
        case let .updateIsLoading(isLoading):
            newState.isLoading = isLoading
        }
        return newState
    }
}

extension OnboardingProfileImageSettingViewReactor {
    
    private func updateImage(_ image: UIImage) -> Observable<Mutation> {
        return self.presignedURL()
            .withUnretained(self)
            .flatMapLatest { object, presignedResponse -> Observable<Mutation> in
                if let imageData = image.jpegData(compressionQuality: 0.5),
                   let url = URL(string: presignedResponse.strUrl) {
                    return object.provider.networkManager.upload(imageData, to: url)
                        .flatMapLatest { _ -> Observable<Mutation> in
                            return .just(.updateImage(image))
                        }
                } else {
                    return .empty()
                }
            }
    }
    
    private func presignedURL() -> Observable<(strUrl: String, imageName: String)> {
        let request: JoinRequest = .profileImagePresignedURL
        
        return self.provider.networkManager.request(PresignedStorageResponse.self, request: request)
            .withUnretained(self)
            .flatMapLatest { object, response -> Observable<(strUrl: String, imageName: String)> in
                object.imageName = response.imgName
                let result = (response.url.url, response.imgName)
                return .just(result)
            }
    }
}

extension OnboardingProfileImageSettingViewReactor {
    
    func reactorForMainTabBar() -> MainTabBarReactor {
        MainTabBarReactor(provider: self.provider)
    }
}
