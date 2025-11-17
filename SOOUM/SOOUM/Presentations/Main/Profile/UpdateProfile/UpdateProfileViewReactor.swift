//
//  UpdateProfileViewReactor.swift
//  SOOUM
//
//  Created by 오현식 on 12/5/24.
//

import ReactorKit

import Kingfisher


class UpdateProfileViewReactor: Reactor {
    
    enum ErrorMessages: String {
        case isEmpty = "한글자 이상 입력해주세요"
        case inValid = "부적절한 닉네임입니다. 다시 입력해주세요"
    }
    
    enum Action: Equatable {
        case uploadImage(UIImage)
        case setDefaultImage
        case setInitialImage
        case checkValidate(String)
        case updateProfile(String)
    }
    
    enum Mutation {
        case updateImageInfo(UIImage?, String?)
        case updateIsValid(Bool)
        case updateIsSuccess(Bool)
        case updateIsProcessing(Bool)
        case updateErrors(Bool?)
        case updateErrorMessage(String?)
    }
    
    struct State {
        var profileImage: UIImage?
        var profileImageName: String?
        var isValid: Bool
        var isUpdatedSuccess: Bool
        var isProcessing: Bool
        var hasErrors: Bool?
        var errorMessage: String?
    }
    
    var initialState: State
    
    private var imageName: String?
    
    private let dependencies: AppDIContainerable
    private let userUseCase: UserUseCase
    
    let nickname: String
    
    init(
        dependencies: AppDIContainerable,
        nickname: String,
        image profileImage: UIImage?
    ) {
        self.dependencies = dependencies
        self.userUseCase = dependencies.rootContainer.resolve(UserUseCase.self)
        self.nickname = nickname
        
        self.initialState = .init(
            profileImage: profileImage,
            isValid: false,
            isUpdatedSuccess: false,
            isProcessing: false,
            hasErrors: nil,
            errorMessage: nil
        )
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .uploadImage(image):
            
            return .concat([
                .just(.updateErrors(nil)),
                self.uploadImage(image)
                    .catch(self.catchClosure)
            ])
        case .setDefaultImage:
            
            return .just(.updateImageInfo(self.initialState.profileImage, nil))
        case .setInitialImage:
            
            return .just(.updateImageInfo(nil, nil))
        case let .checkValidate(nickname):
            
            guard nickname != self.nickname else {
                return .concat([
                    .just(.updateIsValid(false)),
                    .just(.updateErrorMessage(nil))
                ])
            }
            
            if nickname.isEmpty {
                return .concat([
                    .just(.updateIsValid(false)),
                    .just(.updateErrorMessage(ErrorMessages.isEmpty.rawValue))
                ])
            }
            
            return .concat([
                .just(.updateErrorMessage(nil)),
                self.userUseCase.isNicknameValid(nickname: nickname)
                    .withUnretained(self)
                    .flatMapLatest { object, isValid -> Observable<Mutation> in
                        
                        let errorMessage = isValid ? nil : ErrorMessages.inValid.rawValue
                        return .concat([
                            .just(.updateIsValid(isValid)),
                            .just(.updateErrorMessage(errorMessage))
                        ])
                    }
            ])
        case let .updateProfile(nickname):
            
            let trimedNickname = nickname.trimmingCharacters(in: .whitespacesAndNewlines)
            let updatedNickname = trimedNickname == self.nickname ? nil : trimedNickname
            return self.userUseCase.updateMyProfile(
                nickname: updatedNickname,
                imageName: self.currentState.profileImageName
            )
                .map(Mutation.updateIsSuccess)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState: State = state
        switch mutation {
        case let .updateImageInfo(profileImage, profileImageName):
            newState.profileImage = profileImage
            newState.profileImageName = profileImageName
        case let .updateIsValid(isValid):
            newState.isValid = isValid
        case let .updateIsSuccess(isUpdatedSuccess):
            newState.isUpdatedSuccess = isUpdatedSuccess
        case let .updateIsProcessing(isProcessing):
            newState.isProcessing = isProcessing
        case let .updateErrors(hasErrors):
            newState.hasErrors = hasErrors
        case let .updateErrorMessage(errorMessage):
            newState.errorMessage = errorMessage
        }
        return newState
    }
}

extension UpdateProfileViewReactor {
    
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
                .just(.updateIsProcessing(false)),
                // 부적절한 이미지 업로드 에러 코드 == 422
                .just(.updateErrors(nsError.code == 422))
            ])
            
            return endProcessing
        }
    }
}
