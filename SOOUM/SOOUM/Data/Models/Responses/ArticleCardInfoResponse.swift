//
//  ArticleCardInfoResponse.swift
//  SOOUM
//
//  Created by 오현식 on 1/31/26.
//

import Alamofire

struct HomeArticleCardInfoResponse {
    
    let articleInfos: [ArticleCardInfo]
}

extension HomeArticleCardInfoResponse: EmptyResponse {
    
    static func emptyValue() -> HomeArticleCardInfoResponse {
        HomeArticleCardInfoResponse(articleInfos: [])
    }
}

extension HomeArticleCardInfoResponse: Decodable {

    init(from decoder: any Decoder) throws {
        let singleContainer = try decoder.singleValueContainer()
        self.articleInfos = try singleContainer.decode([ArticleCardInfo].self)
    }
}
