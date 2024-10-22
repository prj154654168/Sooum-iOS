//
//  WriteCardViewReactor.swift
//  SOOUM
//
//  Created by 오현식 on 10/20/24.
//

import ReactorKit


class WriteCardViewReactor: Reactor {
    
    enum Action: Equatable {
        case refresh
        case writeCard
        case relatedTags(String)
    }
    
    enum Mutation {
        case updateCard
        case updateRelatedTags
    }
    
    struct State { }
    
    var initialState: State {
        .init()
    }
    
    init() { }
}
