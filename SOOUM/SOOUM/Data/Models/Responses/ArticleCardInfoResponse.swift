//
//  ArticleCardInfoResponse.swift
//  SOOUM
//
//  Created by 오현식 on 1/31/26.
//

import Alamofire

struct HomeArticleCardInfoResponse {
    
    let articleInfo: ArticleCardInfo
}

extension HomeArticleCardInfoResponse: EmptyResponse {
    
    static func emptyValue() -> HomeArticleCardInfoResponse {
        HomeArticleCardInfoResponse(articleInfo: ArticleCardInfo.defaultValue)
    }
}

extension HomeArticleCardInfoResponse: Decodable {
    
    enum CodingKeys: String, CodingKey {
        case articleInfo
    }
    
    init(from decoder: any Decoder) throws {
        let singleContainer = try decoder.singleValueContainer()
        self.articleInfo = try singleContainer.decode(ArticleCardInfo.self)
    }
}
