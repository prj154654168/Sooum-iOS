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
        case writeCard(
            isDistanceShared: Bool,
            isPublic: Bool,
            isStory: Bool,
            content: String,
            font: String,
            imgType: String,
            imgName: String,
            feedTags: [String]
        )
        case writeComment(
            isDistanceShared: Bool,
            content: String,
            font: String,
            imgType: String,
            imgName: String,
            commentTags: [String]
        )
        case relatedTags(keyword: String)
    }
    
    enum Mutation {
        case updateBanEndAt(Date?)
        case writeCard(Bool)
        case relatedTags([RelatedTag])
    }
    
    struct State {
        var banEndAt: Date?
        var isWrite: Bool?
        var relatedTags: [RelatedTag]
    }
    
    var initialState: State = .init(
        banEndAt: nil,
        isWrite: nil,
        relatedTags: []
    )
    
    let provider: ManagerProviderType
    
    let requestType: RequestType
    
    private let parentCardId: String?
    let parentPungTime: Date?
    
    init(
        provider: ManagerProviderType,
        type requestType: RequestType,
        parentCardId: String? = nil,
        parentPungTime: Date? = nil
    ) {
        self.provider = provider
        self.requestType = requestType
        self.parentCardId = parentCardId
        self.parentPungTime = parentPungTime
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .landing:
            
            return self.provider.networkManager.request(SettingsResponse.self, request: SettingsRequest.activate)
                .flatMapLatest { response -> Observable<Mutation> in
                    return .just(.updateBanEndAt(response.banEndAt))
                }
        case let .writeCard(
            isDistanceShared,
            isPublic,
            isStory,
            content,
            font,
            imgType,
            imgName,
            feedTags
        ):
            let coordinate = self.provider.locationManager.coordinate
            let trimedContent = content.trimmingCharacters(in: .whitespacesAndNewlines)
            
            let request: CardRequest = .writeCard(
                isDistanceShared: !isDistanceShared,
                latitude: coordinate.latitude,
                longitude: coordinate.longitude,
                isPublic: !isPublic,
                isStory: isStory,
                content: trimedContent,
                font: font,
                imgType: imgType,
                imgName: imgName,
                feedTags: feedTags
            )
            
            return self.provider.networkManager.request(Status.self, request: request)
                .map { .writeCard($0.httpCode == 201) }
        case let .writeComment(
            isDistanceShared,
            content,
            font,
            imgType,
            imgName,
            commentTags
        ):
            let coordinate = self.provider.locationManager.coordinate
            let trimedContent = content.trimmingCharacters(in: .whitespacesAndNewlines)
            
            let request: CardRequest = .writeComment(
                id: self.parentCardId ?? "",
                isDistanceShared: !isDistanceShared,
                latitude: coordinate.latitude,
                longitude: coordinate.longitude,
                content: trimedContent,
                font: font,
                imgType: imgType,
                imgName: imgName,
                commentTags: commentTags
            )
            
            return self.provider.networkManager.request(Status.self, request: request)
                .map { .writeCard($0.httpCode == 201) }
        case let .relatedTags(keyword):
            
            let request: CardRequest = .relatedTag(keyword: keyword, size: 5)
            return self.provider.networkManager.request(RelatedTagResponse.self, request: request)
                .map(\.embedded.relatedTags)
                .map { .relatedTags($0) }
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state: State = state
        switch mutation {
        case let .updateBanEndAt(banEndAt):
            state.banEndAt = banEndAt
        case let .writeCard(isWrite):
            state.isWrite = isWrite
        case let .relatedTags(relatedTags):
            state.relatedTags = relatedTags
        }
        return state
    }
}

extension WriteCardViewReactor {
    
    func reactorForUploadCard() -> UploadCardBottomSheetViewReactor {
        UploadCardBottomSheetViewReactor.init(
            provider: self.provider,
            type: self.requestType == .card ? .card : .comment
        )
    }
}
