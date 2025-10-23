//
//  NoticeInfo.swift
//  SOOUM
//
//  Created by 오현식 on 9/26/25.
//

import UIKit

struct NoticeInfo {
    
    let id: String
    let noticeType: NoticeType
    let message: String
    let url: String?
    let createdAt: Date
}

extension NoticeInfo {
    
    enum NoticeType: String, Decodable {
        case announcement = "ANNOUNCEMENT"
        case news = "NEWS"
        case maintenance = "MAINTENANCE"
        
        var title: String {
            switch self {
            case .announcement:
                return "서비스 안내"
            case .news:
                return "숨 새소식"
            case .maintenance:
                return "서비스 점검"
            }
        }
        
        var image: UIImage? {
            switch self {
            case .announcement:
                return .init(.icon(.v2(.filled(.headset))))
            case .news:
                return .init(.icon(.v2(.filled(.mail))))
            case .maintenance:
                return .init(.icon(.v2(.filled(.tool))))
            }
        }
        
        var tintColor: UIColor {
            switch self {
            case .announcement:
                return .som.v2.yMain
            case .news:
                return .som.v2.pMain
            case .maintenance:
                return .som.v2.gray400
            }
        }
    }
}

extension NoticeInfo {
    
    static var defaultValue: NoticeInfo = NoticeInfo(
        id: "",
        noticeType: .announcement,
        message: "",
        url: nil,
        createdAt: Date()
    )
}

extension NoticeInfo: Hashable {
    
    static func == (lhs: NoticeInfo, rhs: NoticeInfo) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
}

extension NoticeInfo: Decodable {
    
    enum CodingKeys: String, CodingKey {
        case id
        case noticeType
        case message = "title"
        case url
        case createdAt
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = String(try container.decode(Int64.self, forKey: .id))
        self.noticeType = try container.decode(NoticeType.self, forKey: .noticeType)
        self.message = try container.decode(String.self, forKey: .message)
        self.url = try container.decodeIfPresent(String.self, forKey: .url)
        self.createdAt = try container.decode(Date.self, forKey: .createdAt)
    }
}
