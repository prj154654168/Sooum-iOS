//
//  WriteCardViewReactor.swift
//  SOOUM
//
//  Created by 오현식 on 10/20/24.
//

import ReactorKit


class WriteCardViewReactor: Reactor {
    
    enum RequestType {
        case card
        case comment
    }
    
    enum Action: Equatable {
        case landing
        case updateUserImage(UIImage?, Bool)
        case writeCard(
            isDistanceShared: Bool,
            content: String,
            font: BaseCardInfo.Font,
            imageType: BaseCardInfo.ImageType,
            imageName: String?,
            isStory: Bool,
            tags: [String]
        )
        // case writeComment(
        //     isDistanceShared: Bool,
        //     content: String,
        //     font: String,
        //     imgType: String,
        //     imgName: String,
        //     commentTags: [String]
        // )
        case relatedTags(keyword: String)
        case updateRelatedTags
    }
    
    enum Mutation {
        case defaultImages(DefaultImages)
        case updateUserImage(UIImage?, Bool)
        case writeCard(Bool)
        case relatedTags([TagInfo])
        case updateIsProcessing(Bool)
        case updateErrors(Int?)
    }
    
    struct State {
        fileprivate(set) var shouldUseCoordinates: Bool
        fileprivate(set) var defaultImages: DefaultImages?
        fileprivate(set) var userImage: UIImage?
        fileprivate(set) var isDownloaded: Bool?
        fileprivate(set) var isWritten: Bool?
        fileprivate(set) var relatedTags: [TagInfo]?
        fileprivate(set) var isProcessing: Bool
        fileprivate(set) var hasErrors: Int?
    }
    
    var initialState: State = .init(
        shouldUseCoordinates: false,
        defaultImages: nil,
        userImage: nil,
        isDownloaded: nil,
        isWritten: nil,
        relatedTags: nil,
        isProcessing: false,
        hasErrors: nil
    )
    
    private let dependencies: AppDIContainerable
    private let cardUseCase: CardUseCase
    private let tagUseCase: TagUseCase
    private let userUseCase: UserUseCase
    
    let locationManager: LocationManagerDelegate
    
    private let requestType: RequestType
    
    // let parentCardId: String?
    // let parentPungTime: Date?
    
    init(
        dependencies: AppDIContainerable,
        type requestType: RequestType
        // parentCardId: String? = nil,
        // parentPungTime: Date? = nil
    ) {
        self.dependencies = dependencies
        self.cardUseCase = dependencies.rootContainer.resolve(CardUseCase.self)
        self.tagUseCase = dependencies.rootContainer.resolve(TagUseCase.self)
        self.userUseCase = dependencies.rootContainer.resolve(UserUseCase.self)
        self.locationManager = dependencies.rootContainer.resolve(ManagerProviderType.self).locationManager
        self.requestType = requestType
        // self.parentCardId = parentCardId
        // self.parentPungTime = parentPungTime
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .landing:
            
            return self.cardUseCase.defaultImages().map(Mutation.defaultImages)
            
        case let .updateUserImage(userImage, isDownloaded):
            
            return .just(.updateUserImage(userImage, isDownloaded))
        case let .writeCard(
            isDistanceShared,
            content,
            font,
            imageType,
            imageName,
            isStory,
            tags
        ):
            
            return .concat([
                .just(.updateIsProcessing(true)),
                .just(.updateErrors(nil)),
                self.writeCard(
                    isDistanceShared: isDistanceShared,
                    content: content,
                    font: font,
                    imageType: imageType,
                    imageName: imageName,
                    isStory: isStory,
                    tags: tags
                )
                .delay(.milliseconds(1000), scheduler: MainScheduler.instance),
                .just(.updateIsProcessing(false))
            ])
        // case let .writeComment(
        //     isDistanceShared,
        //     content,
        //     font,
        //     imgType,
        //     imgName,
        //     commentTags
        // ):
        //     let coordinate = self.provider.locationManager.coordinate
        //     let trimedContent = content.trimmingCharacters(in: .whitespacesAndNewlines)
        //
        //     let request: CardRequest = .writeComment(
        //         id: self.parentCardId ?? "",
        //         isDistanceShared: !isDistanceShared,
        //         latitude: coordinate.latitude,
        //         longitude: coordinate.longitude,
        //         content: trimedContent,
        //         font: font,
        //         imgType: imgType,
        //         imgName: imgName,
        //         commentTags: commentTags
        //     )
        //
        //     return self.provider.networkManager.request(Status.self, request: request)
        //         .map { .writeCard($0.httpCode == 201) }
        //         .catch(self.catchClosure)
        case let .relatedTags(keyword):
            
            return self.tagUseCase.relatedTags(keyword: keyword, size: 8)
                .map(Mutation.relatedTags)
        case .updateRelatedTags:
            
            return .just(.relatedTags([]))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case let .defaultImages(defaultImages):
            newState.defaultImages = defaultImages
        case let .updateUserImage(userImage, isDownloaded):
            newState.userImage = userImage
            newState.isDownloaded = isDownloaded
        case let .writeCard(isWritten):
            newState.isWritten = isWritten
        case let .relatedTags(relatedTags):
            newState.relatedTags = relatedTags
        case let .updateIsProcessing(isProcessing):
            newState.isProcessing = isProcessing
        case let .updateErrors(hasErrors):
            newState.hasErrors = hasErrors
        }
        return newState
    }
}

private extension WriteCardViewReactor {
    
    func uploadImage(_ image: UIImage) -> Observable<String?> {
        
        return self.userUseCase.presignedURL()
            .withUnretained(self)
            .flatMapLatest { object, presignedInfo -> Observable<String?> in
                if let imageData = image.jpegData(compressionQuality: 0.5),
                   let url = URL(string: presignedInfo.imgUrl) {
                    
                    return object.userUseCase.uploadImage(imageData, with: url)
                        .flatMapLatest { isSuccess -> Observable<String?> in
                            
                            let imageName = isSuccess ? presignedInfo.imgName : nil
                            return .just(imageName)
                        }
                } else {
                    return .just(nil)
                }
            }
    }
    
    func writeCard(
        isDistanceShared: Bool,
        content: String,
        font: BaseCardInfo.Font,
        imageType: BaseCardInfo.ImageType,
        imageName: String?,
        isStory: Bool,
        tags: [String]
    ) -> Observable<Mutation> {
        
        let coordinate = self.locationManager.coordinate
        let trimedContent = content.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if case .default = imageType, let imageName = imageName {
            
            return self.cardUseCase.writeCard(
                isDistanceShared: isDistanceShared,
                latitude: coordinate.latitude,
                longitude: coordinate.longitude,
                content: trimedContent,
                font: font.rawValue,
                imgType: BaseCardInfo.ImageType.default.rawValue,
                imgName: imageName,
                isStory: isStory,
                tags: tags
            )
            .map(Mutation.writeCard)
        }
        
        if case .user = imageType, let image = self.currentState.userImage {
            
            return self.uploadImage(image)
                .withUnretained(self)
                .flatMapLatest { object, imageName -> Observable<Mutation> in
                    guard let imageName = imageName else { return .just(.writeCard(false)) }
                    
                    return object.cardUseCase.writeCard(
                        isDistanceShared: isDistanceShared,
                        latitude: coordinate.latitude,
                        longitude: coordinate.longitude,
                        content: trimedContent,
                        font: font.rawValue,
                        imgType: BaseCardInfo.ImageType.user.rawValue,
                        imgName: imageName,
                        isStory: isStory,
                        tags: tags
                    )
                    .map(Mutation.writeCard)
                }
        }
        
        return .just(.writeCard(false))
    }
    
    var catchClosure: ((Error) throws -> Observable<Mutation> ) {
        return { error in
            
            let nsError = error as NSError
            return .concat([
                .just(.writeCard(false)),
                .just(.updateIsProcessing(false)),
                .just(.updateErrors(nsError.code))
            ])
        }
    }
}
