//
//  DetailCardInfoResponse.swift
//  SOOUM
//
//  Created by 오현식 on 11/2/25.
//

import Alamofire

struct DetailCardInfoResponse {
    
    let cardInfos: DetailCardInfo
}

extension DetailCardInfoResponse: EmptyResponse {
    
    static func emptyValue() -> DetailCardInfoResponse {
        DetailCardInfoResponse(cardInfos: DetailCardInfo.defaultValue)
    }
}

extension DetailCardInfoResponse: Decodable {
    
    enum CodingKeys: String, CodingKey {
        case cardInfos
    }
    
    init(from decoder: any Decoder) throws {
        let singleContainer = try decoder.singleValueContainer()
        self.cardInfos = try singleContainer.decode(DetailCardInfo.self)
    }
}

struct PollVoteInfoResponse {
    
    let feedCardId: String
    let pollId: String
    let totalVoterCnt: Int64
    let options: [Option]
    
    struct Option {
        let id: String
        let content: String
        let voteCnt: Int64
        let votePercentage: Double
        let isVoted: Bool
    }
}

extension PollVoteInfoResponse: EmptyResponse {
    
    static func emptyValue() -> PollVoteInfoResponse {
        return PollVoteInfoResponse(
            feedCardId: "",
            pollId: "",
            totalVoterCnt: 0,
            options: []
        )
    }
}

extension PollVoteInfoResponse: Decodable {
    
    enum CodingKeys: String, CodingKey {
        case feedCardId
        case pollId
        case totalVoterCnt
        case options
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.feedCardId = String(try container.decode(Int64.self, forKey: .feedCardId))
        self.pollId = String(try container.decode(Int64.self, forKey: .pollId))
        self.totalVoterCnt = try container.decode(Int64.self, forKey: .totalVoterCnt)
        self.options = try container.decode([Option].self, forKey: .options)
    }
}

extension PollVoteInfoResponse.Option: Decodable {
    
    enum CodingKeys: String, CodingKey {
        case id = "pollOptionId"
        case content
        case voteCnt
        case votePercentage
        case isVoted
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = String(try container.decode(Int64.self, forKey: .id))
        self.content = try container.decode(String.self, forKey: .content)
        self.voteCnt = try container.decodeIfPresent(Int64.self, forKey: .voteCnt) ?? 0
        self.votePercentage = try container.decodeIfPresent(Double.self, forKey: .votePercentage) ?? 0
        self.isVoted = try container.decode(Bool.self, forKey: .isVoted)
    }
}

extension PollVoteInfoResponse {
    
    var toDomain: DetailCardInfo.Poll {
        return DetailCardInfo.Poll(
            totalVoterCnt: self.totalVoterCnt,
            isVoted: self.options.contains(where: \.isVoted),
            options: self.options.map {
                .init(
                    id: $0.id,
                    content: $0.content,
                    voteCnt: $0.voteCnt,
                    votePercentage: $0.votePercentage,
                    isVoted: $0.isVoted
                )
            }
        )
    }
}
