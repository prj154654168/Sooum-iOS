//
//  WriteCardViewReactor.swift
//  SOOUM
//
//  Created by 오현식 on 10/20/24.
//

import ReactorKit


class WriteCardViewReactor: Reactor {
    
    enum Action: Equatable {
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
        case relatedTags(keyword: String)
    }
    
    enum Mutation {
        case writeCard(Bool)
        case relatedTags([RelatedTag])
    }
    
    struct State {
        var isWrite: Bool
        var relatedTags: [RelatedTag]
    }
    
    var initialState: State = .init(
        isWrite: false,
        relatedTags: []
    )
    
    private let networkManager = NetworkManager.shared
    private let locationManager = LocationManager.shared
    
    init() { }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
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
            let coordinate = self.locationManager.coordinate
            
            let request: CardRequest = .writeCard(
                isDistanceShared: isDistanceShared,
                latitude: coordinate.latitude,
                longitude: coordinate.longitude,
                isPublic: isPublic,
                isStory: isStory,
                content: content,
                font: font,
                imgType: imgType,
                imgName: imgName,
                feedTags: feedTags
            )
            
            return self.networkManager.request(Status.self, request: request)
                .map { .writeCard($0.httpCode == 201) }
        case let .relatedTags(keyword):
            
            let request: CardRequest = .relatedTag(keyword: keyword, size: 5)
            return self.networkManager.request(RelatedTagResponse.self, request: request)
                .map(\.embedded.relatedTags)
                .map { .relatedTags($0) }
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state: State = state
        switch mutation {
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
        UploadCardBottomSheetViewReactor.init()
    }
}
