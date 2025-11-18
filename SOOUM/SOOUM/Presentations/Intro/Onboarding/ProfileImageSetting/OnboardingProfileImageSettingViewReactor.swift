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
        case uploadImage(UIImage)
        case setDefaultImage
        case signUp
    }
    
    enum Mutation {
        case updateImageInfo(UIImage?, String?)
        case updateIsSignUp(Bool)
        case updateIsLoading(Bool)
        case updateErrors(Bool)
    }
    
    struct State {
        var profileImage: UIImage?
        var profileImageName: String?
        var isSignUp: Bool
        var isLoading: Bool
        var hasErrors: Bool
    }
    
    var initialState: State = .init(
        profileImage: nil,
        profileImageName: nil,
        isSignUp: false,
        isLoading: false,
        hasErrors: false
    )
    
    private let dependencies: AppDIContainerable
    private let userUseCase: UserUseCase
    private let authUseCase: AuthUseCase
    
    private let nickname: String
    
    init(dependencies: AppDIContainerable, nickname: String) {
        self.dependencies = dependencies
        self.userUseCase = dependencies.rootContainer.resolve(UserUseCase.self)
        self.authUseCase = dependencies.rootContainer.resolve(AuthUseCase.self)
        self.nickname = nickname
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .uploadImage(image):
            
            return .concat([
                .just(.updateIsLoading(true)),
                self.uploadImage(image)
                    .catch(self.catchClosure),
                .just(.updateIsLoading(false))
            ])
        case .setDefaultImage:
            
            return .just(.updateImageInfo(nil, nil))
        case .signUp:
            
            return self.signUp()
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case let .updateImageInfo(profileImage, profileImageName):
            newState.profileImage = profileImage
            newState.profileImageName = profileImageName
        case let .updateIsSignUp(isSignUp):
            newState.isSignUp = isSignUp
        case let .updateIsLoading(isLoading):
            newState.isLoading = isLoading
        case let .updateErrors(hasErrors):
            newState.hasErrors = hasErrors
        }
        return newState
    }
}

extension OnboardingProfileImageSettingViewReactor {
    
    private func signUp() -> Observable<Mutation> {
        
        return self.authUseCase.signUp(
            nickname: self.nickname,
            profileImageName: self.currentState.profileImageName
        )
        .map(Mutation.updateIsSignUp)
    }
    
    private func uploadImage(_ image: UIImage) -> Observable<Mutation> {
        
        return self.presignedURL()
            .withUnretained(self)
            .flatMapLatest { object, presignedInfo -> Observable<Mutation> in
                if let imageData = image.jpegData(compressionQuality: 0.5),
                   let url = URL(string: presignedInfo.imgUrl) {
                    
                    return object.userUseCase.uploadImage(imageData, with: url)
                        .flatMapLatest { isSuccess -> Observable<Mutation> in
                            
                            let image = isSuccess ? image : nil
                            let imageName = isSuccess ? presignedInfo.imgName : nil
                            
                            return .just(.updateImageInfo(image, imageName))
                        }
                } else {
                    return .empty()
                }
            }
            .delay(.milliseconds(1000), scheduler: MainScheduler.instance)
    }
    
    private func presignedURL() -> Observable<ImageUrlInfo> {
        
        return self.userUseCase.presignedURL()
    }
    
    private var catchClosure: ((Error) throws -> Observable<Mutation> ) {
        return { error in
            
            let nsError = error as NSError
            let endProcessing = Observable<Mutation>.concat([
                // TODO: 부적절한 사진일 때, `확인` 버튼 탭 시 이미지 변경
                // .just(.updateImageInfo(nil, nil)),
                .just(.updateIsSignUp(false)),
                .just(.updateIsLoading(false)),
                // 부적절한 이미지 업로드 에러 코드 == 422
                .just(.updateErrors(nsError.code == 422))
            ])
            
            return endProcessing
        }
    }
}

extension OnboardingProfileImageSettingViewReactor {
    
    func reactorForCompleted() -> OnboardingCompletedViewReactor {
        OnboardingCompletedViewReactor(dependencies: self.dependencies)
    }
}
