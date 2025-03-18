//
//  SOMEvent.swift
//  SOOUM
//
//  Created by JDeoks on 3/11/25.
//

enum SOMEvent {
  enum WriteCard: FirebaseLoggable {
    /// 태그를 추가하고 글을 작성하지 않을 때
    case dismiss_with_tag(tag_count: Int, tag_texts: [String])
    /// 태그를 추가하고 글을 작성할 때
    case add_tag(tag_count: Int, tag_texts: [String])
  }
  
  enum Tag: FirebaseLoggable {
    enum ClickPositionKey {
      static let post = "post"
      static let tag_page = "tag_page"
      static let recommendation = "recommendation"
      static let search_result = "search_result"
    }
    /// 태그를 클릭
    case tag_click(tag_text: String, click_position: String)
  }
  
  enum Comment: FirebaseLoggable {
    case add_comment(comment_length: Int, parent_post_id: String, image_attached: Bool)
  }
}
