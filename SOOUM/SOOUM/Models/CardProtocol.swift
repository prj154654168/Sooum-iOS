//
//  CardProtocol.swift
//  SOOUM
//
//  Created by 오현식 on 9/27/24.
//

import Foundation


/// 서버 응답 코드가 204 or response.data == nil일 때
protocol EmptyInitializable {
    static func empty() -> Self
}

/// 서버 응답 status
struct Status: Codable {
    let httpCode: Int
    let httpStatus: String
    let responseMessage: String
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.httpCode = try container.decode(Int.self, forKey: .httpCode)
        self.httpStatus = try container.decode(String.self, forKey: .httpStatus)
        self.responseMessage = try container.decode(String.self, forKey: .responseMessage)
    }
    
    init() {
        self.httpCode = 0
        self.httpStatus = ""
        self.responseMessage = ""
    }
}

protocol CardProtocol: Equatable, Codable {
    var id: String { get }
    var content: String { get }
    
    var distance: Double? { get }
    
    var createdAt: Date { get }
    var storyExpirationTime: Date? { get }
    
    var backgroundImgURL: URLString { get }
    
    var font: Font { get }
    
    var isStory: Bool { get }
}

/// 다음 카드 URL
struct Next: Codable {
    let next: URLString
}
/// 상세보기 카드 URL
struct Detail: Codable {
    let detail: URLString
}
/// 실제 urlString
struct URLString: Codable {
    let url: String
    
    enum CodingKeys: String, CodingKey {
        case url = "href"
    }
}
/// 사용하는 폰트
enum Font: String, Codable {
    case pretendard = "PRETENDARD"
    case school = "SCHOOL_SAFE_CHALKBOARD_ERASER"
}
/// 사용하는 폰트 사이즈
enum FontSize: String, Codable {
    case big = "BIG"
}
