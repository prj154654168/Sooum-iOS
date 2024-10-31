//
//  CardProtocol.swift
//  SOOUM
//
//  Created by 오현식 on 9/27/24.
//

import Foundation


protocol CardProtocol: Equatable, Codable {
    var id: String { get }
    var content: String { get }
    
    var distance: Double? { get }
    
    var createdAt: Date { get }
    var storyExpirationTime: Date? { get }
    
    var likeCnt: Int { get }
    var commentCnt: Int { get }
    
    var backgroundImgURL: URLString { get }
    
    var font: Font { get }
    var fontSize: FontSize { get }
    
    var isLiked: Bool { get }
    var isCommentWritten: Bool { get }
}

/// 다음 카드 URL
struct Next: Codable {
    let next: URLString
}
extension Next {
    init() {
        self.next = .init()
    }
}
/// 상세보기 카드 URL
struct Detail: Codable {
    let detail: URLString
}
extension Detail {
    init() {
        self.detail = .init()
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
