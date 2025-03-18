//
//  SOMEvent.swift
//  SOOUM
//
//  Created by JDeoks on 3/11/25.
//

enum SOMEvent {
  enum WriteCard: AnalyticsEventProtocol {
    /// 글쓰기 화면에서 태그를 추가하고 글을 작성하지 않음
    case dismiss_with_tag(tag_count: Int, tag_texts: [String])
    /// 글쓰기 화면에서 태그를 추가하고 글을 작성
    case add_tag(tag_count: Int, tag_texts: [String])
  }
  
  enum Tag: AnalyticsEventProtocol {
    /// 태그를 클릭한 위치
    enum ClickPositionKey {
      /// 카드 상세화면에서 태그 클릭
      static let post = "post"
      /// 추천 태그 목록에서 태그 클릭
      static let recommendation = "recommendation"
      /// 태그 검색 결과에서 태그 클릭
      static let search_result = "search_result"
    }
    /// 태그를 클릭
    case tag_click(tag_text: String, click_position: String)
  }
  
  enum Comment: AnalyticsEventProtocol {
    /// 사용자가 댓글을 작성
    ///
    /// - Parameters:
    ///  - comment_length: 댓글 길이
    ///  - parent_post_id: 부모 글 ID
    ///  - image_attached: 이미지 첨부 여부
    case add_comment(comment_length: Int, parent_post_id: String, image_attached: Bool)
  }
}
