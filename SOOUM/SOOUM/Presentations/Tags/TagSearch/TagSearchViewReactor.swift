//
//  TagSearchViewReactor.swift
//  SOOUM
//
//  Created by JDeoks on 12/4/24.
//

import ReactorKit

class TagSearchViewReactor: Reactor {
    
    enum Action {
        case searchTag(String)
//        case selectTag(String)
    }
    
    enum Mutation {
        /// 즐겨찾기 태그 fetch
        case searchTags([SearchTagsResponse.RelatedTag])
//        case setSelectTagFinished
    }
    
    struct State {
        /// 즐겨찾기 태그 리스트
        fileprivate(set) var searchTags: [SearchTagsResponse.RelatedTag] = []
        /// 추천 태그 리스트
//        fileprivate(set) var recommendTags: [RecommendTagsResponse.RecommendTag] = []
    }
    
    var initialState = State()
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .searchTag(keyword):
            return self.searchTags(keyword: keyword)
            
//        case .selectTag(String)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case let .searchTags(searchTags):
            newState.searchTags = searchTags
            
//        case let .recommendTags(recommendTags):
//            newState.recommendTags = recommendTags
        }
        return newState
    }
    
    private func searchTags(keyword: String) -> Observable<Mutation> {
        let request: TagRequest = .search(keyword: keyword)
        if keyword.isEmpty {
            return .just(.searchTags([]))
        }
        
        return NetworkManager.shared.request(SearchTagsResponse.self, request: request)
            .map { response in
                return Mutation.searchTags(response.embedded.relatedTagList)
            }
            .catch { _ in
                print("\(type(of: self)) - \(#function) - catch")
                return .just(.searchTags([]))
            }
    }
}
