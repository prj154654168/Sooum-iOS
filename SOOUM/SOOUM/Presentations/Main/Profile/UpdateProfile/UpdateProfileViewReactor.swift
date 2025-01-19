//
//  UpdateProfileViewReactor.swift
//  SOOUM
//
//  Created by 오현식 on 12/5/24.
//

import ReactorKit

import Alamofire


class UpdateProfileViewReactor: Reactor {
    
    enum ErrorMessages: String {
        case isEmpty = "한글자 이상 입력해주세요"
        case inValid = "부적절한 닉네임입니다. 다시 입력해주세요"
    }
    
    enum Action: Equatable {
        case updateImage(UIImage)
        case checkValidate(String)
        case updateProfile(String)
    }
    
    enum Mutation {
        case updateImage(UIImage)
        case updateIsValid(Bool)
        case updateIsSuccess(Bool)
        case updateIsProcessing(Bool)
        case updateErrorMessage(String?)
    }
    
    struct State {
        var profileImage: UIImage?
        var isValid: Bool
        var isSuccess: Bool
        var isProcessing: Bool
        var errorMessage: String?
    }
    
    var initialState: State = .init(
        profileImage: nil,
        isValid: false,
        isSuccess: false,
        isProcessing: false,
        errorMessage: nil
    )
    
    private var imageName: String?
    
    let provider: ManagerProviderType
    var profile: Profile
    
    init(provider: ManagerProviderType, _ profile: Profile) {
        self.provider = provider
        self.profile = profile
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .checkValidate(nickname):
            if nickname.isEmpty {
                return .concat([
                    .just(.updateIsValid(false)),
                    .just(.updateErrorMessage(ErrorMessages.isEmpty.rawValue))
                ])
            }
            let request: JoinRequest = .validateNickname(nickname: nickname)
            
            return .concat([
                .just(.updateErrorMessage(nil)),
                self.provider.networkManager.request(NicknameValidationResponse.self, request: request)
                    .flatMapLatest { response -> Observable<Mutation> in
                        let isAvailable = response.isAvailable
                        let errorMessage = isAvailable ? nil : ErrorMessages.inValid.rawValue
                        return .concat([
                            .just(.updateIsValid(isAvailable)),
                            .just(.updateErrorMessage(errorMessage))
                        ])
                    }
            ])
        case let .updateImage(image):
            return self.updateImage(image)
        case let .updateProfile(nickname):
            let trimedNickname = nickname.trimmingCharacters(in: .whitespacesAndNewlines)
            let request: ProfileRequest = .updateProfile(nickname: trimedNickname, profileImg: self.imageName)
            
            return .concat([
                .just(.updateIsProcessing(true)),
                
                self.provider.networkManager.request(Empty.self, request: request)
                    .flatMapLatest { _ -> Observable<Mutation> in
                        return .just(.updateIsSuccess(true))
                    },
                
                .just(.updateIsProcessing(false))
            ])
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
        case let .updateIsValid(isValid):
            state.isValid = isValid
        case let .updateImage(profileImage):
            state.profileImage = profileImage
        case let .updateIsSuccess(isSuccess):
            state.isSuccess = isSuccess
        case let .updateIsProcessing(isProcessing):
            state.isProcessing = isProcessing
        case let .updateErrorMessage(errorMessage):
            state.errorMessage = errorMessage
        }
        return state
    }
}

extension UpdateProfileViewReactor {
    
    private func updateImage(_ image: UIImage) -> Observable<Mutation> {
        return self.presignedURL()
            .withUnretained(self)
            .flatMapLatest { object, presignedResponse -> Observable<Mutation> in
                if let imageData = image.jpegData(compressionQuality: 0.5),
                   let url = URL(string: presignedResponse.strUrl) {
                    return object.provider.networkManager.upload(imageData, to: url)
                        .flatMapLatest { _ -> Observable<Mutation> in
                            return .empty()
                        }
                }
                return .empty()
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
