//
//  AnnouncementResponse.swift
//  SOOUM
//
//  Created by 오현식 on 12/6/24.
//

import Foundation

import Alamofire


struct AnnouncementResponse: Codable {
    let embedded: AnnouncementEmbedded
    let links: AnnouncementLinks
    let status: Status
    
    enum CodingKeys: String, CodingKey {
        case embedded = "_embedded"
        case links = "_links"
        case status
    }
}

extension AnnouncementResponse {
    
    init() {
        self.embedded = .init()
        self.links = .init()
        self.status = .init()
    }
}

extension AnnouncementResponse: EmptyResponse {
    static func emptyValue() -> AnnouncementResponse {
        AnnouncementResponse.init()
    }
}

struct AnnouncementLinks: Codable {
    let `self`: URLString
}

extension AnnouncementLinks {
    
    init() {
        self.`self` = .init()
    }
}

struct AnnouncementEmbedded: Codable {
    let announcements: [Announcement]
    
    enum CodingKeys: String, CodingKey {
        case announcements = "noticeDtoList"
    }
}

extension AnnouncementEmbedded {
    
    init() {
        self.announcements = []
    }
}

struct Announcement: Equatable, Codable {
    let id: Int
    let noticeType: NoticeType
    let noticeDate: String
    let title: String
    let link: String
}

extension Announcement {
    
    init() {
        self.id = 0
        self.noticeType = .announcement
        self.noticeDate = ""
        self.title = ""
        self.link = ""
    }
}

enum NoticeType: String, Codable {
    case maintenance = "MAINTENANCE"
    case announcement = "ANNOUNCEMENT"
}
