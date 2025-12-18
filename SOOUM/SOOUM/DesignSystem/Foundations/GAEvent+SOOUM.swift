//
//  GAEvent+SOOUM.swift
//  SOOUM
//
//  Created by 오현식 on 12/13/25.
//

enum GAEvent {
    
    
    // MARK: SOOUM v1
    
    // enum WriteCard: AnalyticsEventProtocol {
    //     /// 글쓰기 화면에서 태그를 추가하고 글을 작성하지 않음
    //     case dismiss_with_tag(tag_count: Int, tag_texts: [String])
    //     /// 글쓰기 화면에서 태그를 추가하고 글을 작성
    //     case add_tag(tag_count: Int, tag_texts: [String])
    // }
    
    // enum Tag: AnalyticsEventProtocol {
    //     /// 태그를 클릭한 위치
    //     enum ClickPositionKey {
    //         /// 카드 상세화면에서 태그 클릭
    //         static let post = "post"
    //         /// 즐겨찾기 태그 목록에서 태그 클릭
    //         static let favorite = "favorite"
    //         /// 즐겨찾기 태그 목록의 미리보기 카드 클릭
    //         static let favorite_preview = "favorite_preview"
    //         /// 추천 태그 목록에서 태그 클릭
    //         static let recommendation = "recommendation"
    //         /// 태그 검색 결과에서 태그 클릭
    //         static let search_result = "search_result"
    //     }
    //     /// 태그를 클릭
    //     case tag_click(tag_text: String, click_position: String)
    // }
    
    // enum Comment: AnalyticsEventProtocol {
    //     /// 사용자가 댓글을 작성
    //     ///
    //     /// - Parameters:
    //     ///  - comment_length: 댓글 길이
    //     ///  - parent_post_id: 부모 글 ID
    //     ///  - image_attached: 이미지 첨부 여부
    //     case add_comment(comment_length: Int, parent_post_id: String, image_attached: Bool)
    // }
    
    
    // MARK: SOOUM v2
    
    enum TabBar: AnalyticsEventProtocol {
        /// 바텀 네비게이션에서 ‘카드추가’ 버튼 클릭 이벤트
        case moveToCreateFeedCardView_btn_click
    }
    
    enum HomeView: AnalyticsEventProtocol {
        /// 피드에서 홈 버튼을 클릭하여 피드 최상단으로 이동하는 이벤트
        case feedMoveToTop_home_btn_click
        /// 피드 화면에서 카드 상세보기 이동 이벤트
        case feedToCardDetailView_card_click
        /// 피드 화면에서 이벤트 이미지를 사용한 카드 상세보기 이동 이벤트
        case feedToCardDetailView_cardWithEventImg_click
    }
    
    enum DetailView: AnalyticsEventProtocol {
        /// 카드 상세 조회 클릭 이벤트 (파라미터로 어디서 조회 하는건지 넘겨주기 feed, comment, profile)
        case cardDetailView_tracePath_click(previous_path: ScreenPath)
        /// 카드 상세보기에서 댓글카드 작성 버튼(아이콘 버튼과 플로팅 버튼 모두 포함) 클릭 이벤트
        case moveToCreateCommentCardView_btn_click
        /// 카드 상세보기에서 댓글카드 작성 버튼(좋아요 옆에 있는 버튼) 클릭 이벤트
        case moveToCreateCommentCardView_icon_btn_click
        /// 카드 상세보기에서 우측 하단에 동그란 버튼(플로팅된 댓글카드 작성 버튼) 클릭 이벤트
        case moveToCreateCommentCardView_floating_btn_click
        /// 이벤트 카드의 플로팅 버튼 클릭 이벤트
        case moveToCreateCommentCardView_withEventImg_floating_btn_click
        /// 카드 상세보기 화면에서 태그 영역(특정 태그) 클릭 이벤트
        case cardDetailTag_btn_click(tag_name: String)
    }
    
    enum WriteCardView: AnalyticsEventProtocol {
        /// 피드 카드 작성 뷰에서 뒤로가기 버튼 클릭 이벤트
        case moveToCreateFeedCardView_cancel_btn_click
        /// 댓글카드 작성 뷰에서 뒤로가기 버튼 클릭 이벤트
        case moveToCreateCommentCardView_cancel_btn_click
        /// 피드 카드 작성 뷰에서 태그 추가를 키보드 엔터(완료)버튼 클릭 이벤트
        case multipleFeedTagCreation_enter_btn_click
        /// 피드 카드 작성 뷰에서 기본 배경 이미지 카테고리 변경 클릭 이벤트
        case feedBackgroundCategory_tab_click
        /// 카드 만들기(피드 카드 작성 뷰)에서 ‘이벤트’ 카테고리 버튼 클릭 이벤트
        case createFeedCardEventCategory_btn_click
        /// 댓글카드 작성 뷰에서 기본 배경 이미지 카테고리 변경 클릭 이벤트
        case commentBackgroundCategory_tab_click
        /// 피드 카드 작성 완료 버튼 클릭 이벤트
        case createFeedCard_btn_click
        /// 거리 공유 옵션을 끈 상태로 피드 카드 작성 완료 버튼 클릭 이벤트
        case createFeedCardWithoutDistanceSharedOpt_btn_click
    }
    
    enum TagView: AnalyticsEventProtocol {
        /// 태그 즐겨찾기 등록 버튼 클릭 이벤트(즐겨찾기 취소는 해당 이벤트에 제외)
        case favoriteTagRegister_btn_click
        /// 태그 메뉴 화면에서 검색바 클릭 이벤트
        case tagMenuSearchBar_click
        /// 인기 태그 영역에서 특정 태그 클릭 이벤트
        case popularTag_item_click
    }
    
    enum TransferView: AnalyticsEventProtocol {
        /// 계정이관코드 입력 후 완료 버튼 클릭하여 계정이관 성공한 경우의 이벤트
        case accountTransferSuccess
    }
}

extension GAEvent.DetailView {
    
    enum ScreenPath: String {
        case home
        case detail
        case notification
        case writeCard
        case tag_collect
        case tag_search_collect
        case profile
    }
    
    enum EnterTo: String {
        case icon
        case floating
    }
}
