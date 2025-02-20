//
//  CommentHistoryInNotiResponse.swift
//  SOOUM
//
//  Created by 오현식 on 12/20/24.
//

import Foundation

import Alamofire


struct CommentHistoryInNotiResponse: Codable {
    let commentHistoryInNotis: [CommentHistoryInNoti]
}

extension CommentHistoryInNotiResponse {
    
    init() {
        self.commentHistoryInNotis = []
    }
    
    init(from decoder: any Decoder) throws {
        let singleContainer = try decoder.singleValueContainer()
        self.commentHistoryInNotis = try singleContainer.decode([CommentHistoryInNoti].self)
    }
}

extension CommentHistoryInNotiResponse: EmptyResponse {
    
    static func emptyValue() -> CommentHistoryInNotiResponse {
        CommentHistoryInNotiResponse.init()
    }
}

struct CommentHistoryInNoti: Equatable, Codable {
    let id: Int
    let type: NotificationType
    let createAt: Date
    
    /// 정지되었을 때
    let blockExpirationTime: Date?
    
    /// 공감/답카드 일 때
    let targetCardId: Int?
    let feedCardImgURL: URLStringInNoti?
    let content: String?
    let font: Font?
    let fontSize: FontSize?
    let nickName: String?
    
    enum NotificationType: String, Codable {
        case feedLike = "FEED_LIKE"
        case commentLike = "COMMENT_LIKE"
        case commentWrite = "COMMENT_WRITE"
        case blocked = "BLOCKED"
        case delete = "DELETED"
        case transfer = "TRANSFER_SUCCESS"
        
        var description: String {
            switch self {
            case .feedLike, .commentLike: return "공감"
            case .commentWrite: return "답카드"
            default: return ""
            }
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "notificationId"
        case type = "notificationType"
        case createAt = "createTime"
        case blockExpirationTime = "blockExpirationDateTime"
        case targetCardId
        case feedCardImgURL = "imgUrl"
        case content
        case font
        case fontSize
        case nickName
    }
}

extension CommentHistoryInNoti {
    
    init() {
        self.id = 0
        self.type = .blocked
        self.createAt = Date()
        self.blockExpirationTime = nil
        self.targetCardId = nil
        self.feedCardImgURL = nil
        self.content = nil
        self.font = nil
        self.fontSize = nil
        self.nickName = nil
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.type = try container.decode(NotificationType.self, forKey: .type)
        self.createAt = try container.decode(Date.self, forKey: .createAt)
        self.blockExpirationTime = try container.decodeIfPresent(Date.self, forKey: .blockExpirationTime)
        self.targetCardId = try container.decodeIfPresent(Int.self, forKey: .targetCardId)
        self.feedCardImgURL = try container.decodeIfPresent(URLStringInNoti.self, forKey: .feedCardImgURL)
        self.content = try container.decodeIfPresent(String.self, forKey: .content)
        self.font = try container.decodeIfPresent(Font.self, forKey: .font)
        self.fontSize = try container.decodeIfPresent(FontSize.self, forKey: .fontSize)
        self.nickName = try container.decodeIfPresent(String.self, forKey: .nickName)
    }
}

struct URLStringInNoti: Equatable, Codable {
    let rel: String
    let url: String
    
    enum CodingKeys: String, CodingKey {
        case rel
        case url = "href"
    }
}

extension URLStringInNoti {
    
    init() {
        self.rel = ""
        self.url = ""
    }
}
