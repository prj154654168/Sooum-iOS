//
//  SOMCard.swift
//  SOOUM
//
//  Created by JDeoks on 9/14/24.
//

import UIKit

import SnapKit
import Then

import RxSwift

class SOMCard: UIView {
    
    enum Text {
        static let adminTitle: String = "sooum"
        static let pungedCardText: String = "카드가 삭제되었어요"
    }
    
    
    // MARK: Views
    
    let shadowbackgroundView = UIView().then {
        $0.backgroundColor = .som.v2.white
        $0.layer.cornerRadius = 16
    }
    
    /// 배경 이미지
    let rootContainerImageView = UIImageView().then {
        $0.layer.cornerRadius = 16
        $0.layer.borderWidth = 1
        $0.contentMode = .scaleAspectFill
        $0.layer.masksToBounds = true
    }
    
    // 본문 dim 배경
    let cardTextBackgroundBlurView = UIView().then {
        $0.backgroundColor = .som.v2.dim
        $0.layer.cornerRadius = 12
        $0.clipsToBounds = true
    }
    
    /// 본문 표시 라벨 (스크롤 X)
    let cardTextContentLabel = UILabel().then {
        $0.textColor = .som.v2.white
        $0.typography = .som.v2.body1
        $0.textAlignment = .center
        $0.numberOfLines = 3
        $0.lineBreakMode = .byTruncatingTail
        $0.lineBreakStrategy = .hangulWordPriority
    }
    /// 본문 스크롤 텍스트 뷰 (스크롤 O)
    let cardTextContentScrollView = UITextView().then {
        $0.textColor = .som.v2.white
        $0.typography = .som.v2.body1
        
        $0.backgroundColor = .clear
        $0.tintColor = .clear
        
        $0.textAlignment = .center
        $0.textContainerInset = .init(top: 0, left: 16, bottom: 0, right: 16)
        $0.textContainer.lineFragmentPadding = 0
        
        $0.indicatorStyle = .white
        $0.scrollIndicatorInsets = .init(top: 14, left: 0, bottom: 14, right: 0)
        
        $0.isScrollEnabled = false
        $0.showsVerticalScrollIndicator = true
        $0.showsHorizontalScrollIndicator = false
        
        $0.isEditable = false
    }
    
    /// 펑 시간, 거리, 시간, 좋아요 수, 답글 수 정보를 담는 뷰
    let cardInfoContainer = UIView().then {
        $0.backgroundColor = .som.v2.white
        $0.layer.borderColor = UIColor.som.v2.white.cgColor
        $0.layer.borderWidth = 1
    }
    /// 펑 시간, 거리, 시간을 담는 스택 뷰
    let cardInfoLeadingStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 4
        $0.alignment = .center
    }
    /// 좋아요 수, 답글 수를 담는 스택 뷰
    let cardInfoTrailingStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 4
        $0.alignment = .center
    }
    
    /// 어드민 정보 표시 스택뷰
    let adminStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 2
        $0.alignment = .center
    }
    /// 어드민 정보 아이콘
    let adminImageView = UIImageView().then {
        $0.image = .init(.icon(.v2(.filled(.official))))
        $0.tintColor = .som.v2.black
    }
    /// 어드민 정보 라벨
    let adminLabel = UILabel().then {
        $0.text = Text.adminTitle
        $0.textColor = .som.v2.black
        $0.typography = .som.v2.caption2
    }
    /// 어드민 닷
    let firstDot = UIView().then {
        $0.backgroundColor = .som.v2.gray500
        $0.layer.cornerRadius = 1
    }
    /// 펑 남은시간 표시 스택뷰
    let cardPungTimeStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 2
        $0.alignment = .center
    }
    /// 펑 남은시간 표시 아이콘
    let cardPungTimeImageView = UIImageView().then {
        $0.image = .init(.icon(.v2(.filled(.bomb))))
        $0.tintColor = .som.v2.pMain
    }
    /// 펑 남은시간 표시 라벨
    let cardPungTimeLabel = UILabel().then {
        $0.textColor = .som.v2.pDark
        $0.typography = .som.v2.caption2
    }
    /// 펑 남은시간 닷
    let secondDot = UIView().then {
        $0.backgroundColor = .som.v2.gray500
        $0.layer.cornerRadius = 1
    }
    /// 거리 정보 표시 스택뷰
    let distanceInfoStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 2
        $0.alignment = .center
    }
    /// 거리 정보 아이콘
    let distanceImageView = UIImageView().then {
        $0.image = .init(.icon(.v2(.outlined(.location))))
        $0.tintColor = .som.v2.gray500
    }
    /// 거리 정보 라벨
    let distanceLabel = UILabel().then {
        $0.textColor = .som.v2.gray500
        $0.typography = .som.v2.caption2
    }
    /// 거리 정보 닷
    let thirdDot = UIView().then {
        $0.backgroundColor = .som.v2.gray500
        $0.layer.cornerRadius = 1
    }
    /// 시간 정보 표시 라벨
    let timeLabel = UILabel().then {
        $0.textColor = .som.v2.gray500
        $0.typography = .som.v2.caption2
    }
    /// 좋아요 정보 표시 스택뷰
    let likeInfoStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 2
        $0.alignment = .center
    }
    /// 좋아요 정보 표시 아이콘
    let likeImageView = UIImageView().then {
        $0.image = .init(.icon(.v2(.outlined(.heart))))
        $0.tintColor = .som.v2.gray500
    }
    /// 좋아요 정보 표시 라벨
    let likeLabel = UILabel().then {
        $0.textColor = .som.v2.gray500
        $0.typography = .som.v2.caption2
    }
    /// 답카드 정보 표시 스택뷰
    let commentInfoStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 2
        $0.alignment = .center
    }
    /// 답카드 정보 표시 아이콘
    let commentImageView = UIImageView().then {
        $0.image = .init(.icon(.v2(.outlined(.message_circle))))
        $0.tintColor = .som.v2.gray500
    }
    /// 답카드 정보 표시 라벨
    let commentLabel = UILabel().then {
        $0.textColor = .som.v2.gray500
        $0.typography = .som.v2.caption2
    }
    
    
    // MARK: Variables
    
    var model: BaseCardInfo?
    
    private var hasScrollEnabled: Bool
    
    
    // MARK: Constraints
    
    // TODO: 카드 본문 배경 블러 뷰 높이 계산 Constraint, 헌재 사용 X
    private var contentHeightConstraint: Constraint?
    private var scrollContentHieghtConstraint: Constraint?
    
    /// 펑 이벤트 처리 위해 추가
    var serialTimer: Disposable?
    var disposeBag = DisposeBag()
    
    
    // MARK: Initialize
    
    init(hasScrollEnabled: Bool = false) {
        self.hasScrollEnabled = hasScrollEnabled
        super.init(frame: .zero)
        
        self.setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: Override func
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.shadowbackgroundView.setShadow(
            radius: 6,
            color: UIColor(hex: "#ABBED11A").withAlphaComponent(0.1),
            blur: 16,
            offset: .init(width: 0, height: 6)
        )
    }


    // MARK: private func
    
    private func setupConstraints() {
        
        // 백그라운드 그림자 뷰
        self.addSubview(self.shadowbackgroundView)
        self.shadowbackgroundView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        // 배경 이미지 뷰
        self.addSubview(self.rootContainerImageView)
        self.rootContainerImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        // 하단 카드 정보 컨테이너
        self.rootContainerImageView.addSubview(self.cardInfoContainer)
        self.cardInfoContainer.snp.makeConstraints {
            $0.bottom.horizontalEdges.equalToSuperview()
            $0.height.equalTo(34)
        }
        
        // 좌측
        self.cardInfoContainer.addSubview(self.cardInfoLeadingStackView)
        self.cardInfoLeadingStackView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(16)
            $0.height.equalTo(18)
        }
        
        self.adminStackView.addArrangedSubview(self.adminImageView)
        self.adminStackView.addArrangedSubview(self.adminLabel)
        self.adminImageView.snp.makeConstraints {
            $0.size.equalTo(16)
        }
        
        self.cardPungTimeStackView.addArrangedSubview(self.cardPungTimeImageView)
        self.cardPungTimeStackView.addArrangedSubview(self.cardPungTimeLabel)
        self.cardPungTimeImageView.snp.makeConstraints {
            $0.size.equalTo(16)
        }
        
        self.distanceInfoStackView.addArrangedSubview(self.distanceImageView)
        self.distanceInfoStackView.addArrangedSubview(self.distanceLabel)
        self.distanceImageView.snp.makeConstraints {
            $0.size.equalTo(14)
        }
        
        self.cardInfoLeadingStackView.addArrangedSubview(self.adminStackView)
        self.cardInfoLeadingStackView.addArrangedSubview(self.firstDot)
        self.firstDot.snp.makeConstraints {
            $0.size.equalTo(2)
        }
        
        self.cardInfoLeadingStackView.addArrangedSubview(self.cardPungTimeStackView)
        self.cardInfoLeadingStackView.addArrangedSubview(self.secondDot)
        self.secondDot.snp.makeConstraints {
            $0.size.equalTo(2)
        }
        
        self.cardInfoLeadingStackView.addArrangedSubview(self.distanceInfoStackView)
        self.cardInfoLeadingStackView.addArrangedSubview(self.thirdDot)
        self.thirdDot.snp.makeConstraints {
            $0.size.equalTo(2)
        }
        self.cardInfoLeadingStackView.addArrangedSubview(self.timeLabel)
        
        // 우측
        self.cardInfoContainer.addSubview(self.cardInfoTrailingStackView)
        self.cardInfoTrailingStackView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.greaterThanOrEqualTo(self.cardInfoLeadingStackView.snp.trailing).offset(4)
            $0.trailing.equalToSuperview().offset(-16)
            $0.height.equalTo(18)
        }
        
        self.likeInfoStackView.addArrangedSubview(self.likeImageView)
        self.likeInfoStackView.addArrangedSubview(self.likeLabel)
        self.likeImageView.snp.makeConstraints {
            $0.size.equalTo(14)
        }
        
        self.commentInfoStackView.addArrangedSubview(self.commentImageView)
        self.commentInfoStackView.addArrangedSubview(self.commentLabel)
        self.commentImageView.snp.makeConstraints {
            $0.size.equalTo(14)
        }
        
        self.cardInfoTrailingStackView.addArrangedSubview(self.likeInfoStackView)
        self.cardInfoTrailingStackView.addArrangedSubview(self.commentInfoStackView)
        
        // 카드 문구
        self.rootContainerImageView.addSubview(self.cardTextBackgroundBlurView)
        self.cardTextBackgroundBlurView.snp.makeConstraints {
            $0.centerY.equalToSuperview().offset(-34 * 0.5)
            $0.leading.equalToSuperview().offset(32)
            $0.trailing.equalToSuperview().offset(-32)
        }
        
        if self.hasScrollEnabled {
            self.cardTextBackgroundBlurView.addSubview(self.cardTextContentScrollView)
            self.cardTextContentScrollView.snp.makeConstraints {
                $0.top.equalToSuperview().offset(20)
                $0.bottom.equalToSuperview().offset(-20)
                $0.leading.equalToSuperview().offset(24)
                $0.trailing.equalToSuperview().offset(-24)
            }
        } else {
            self.cardTextBackgroundBlurView.addSubview(self.cardTextContentLabel)
            self.cardTextContentLabel.snp.makeConstraints {
                $0.top.equalToSuperview().offset(20)
                $0.bottom.equalToSuperview().offset(-20)
                $0.leading.equalToSuperview().offset(24)
                $0.trailing.equalToSuperview().offset(-24)
            }
        }
    }
    
    
    // MARK: Public func
    
    /// 이 컴포넌트를 사용하는 재사용 셀에서 호출
    func prepareForReuse() {
        self.serialTimer?.dispose()
        self.disposeBag = DisposeBag()
    }
    
    /// 홈피드 모델 초기화
    func setModel(model: BaseCardInfo) {
        
        self.model = model
        // 카드 배경 이미지
        self.rootContainerImageView.setImage(strUrl: model.cardImgURL, with: model.cardImgName)
        self.rootContainerImageView.layer.borderColor = model.isAdminCard ? UIColor.som.v2.pMain.cgColor : UIColor.som.v2.gray100.cgColor
        
        // 카드 본문
        let typography: Typography
        switch model.font {
        case .pretendard:   typography = .som.v2.body1
        case .ridi:         typography = .som.v2.ridiCard
        case .yoonwoo:      typography = .som.v2.yoonwooCard
        case .kkookkkook:   typography = .som.v2.kkookkkookCard
        }
        if self.hasScrollEnabled {
            self.cardTextContentScrollView.text = model.cardContent
            self.cardTextContentScrollView.typography = typography
        } else {
            self.cardTextContentLabel.text = model.cardContent
            self.cardTextContentLabel.typography = typography
        }
        
        // 하단 정보
        // 어드민, 펑 시간, 거리, 시간
        self.adminStackView.isHidden = model.isAdminCard == false
        self.firstDot.isHidden = model.isAdminCard == false
        self.cardPungTimeStackView.isHidden = model.storyExpirationTime == nil
        self.secondDot.isHidden = model.storyExpirationTime == nil
        self.distanceLabel.text = model.distance
        self.distanceInfoStackView.isHidden = model.distance == nil
        self.thirdDot.isHidden = model.distance == nil
        self.timeLabel.text = model.createdAt.toKorea().infoReadableTimeTakenFromThis(to: Date().toKorea())
        
        // 좋아요 수, 답글 수
        let likeText = model.likeCnt > 99 ? "99+" : "\(model.likeCnt)"
        self.likeLabel.attributedText = .init(string: likeText, attributes: Typography.som.v2.caption2.attributes)
        
        let commentText = model.commentCnt > 99 ? "99+" : "\(model.commentCnt)"
        self.commentLabel.attributedText = .init(string: commentText, attributes: Typography.som.v2.caption2.attributes)
        
        // 스토리 정보 설정
        self.subscribePungTime(model.storyExpirationTime)
    }
    
    func setData(tagCard: TagDetailCardResponse.TagFeedCard) {
        
        // 카드 배경 이미지
//        rootContainerImageView.setImage(strUrl: tagCard.backgroundImgURL.href)
//        // 카드 본문
//        updateContentHeight(tagCard.content)
//        let typography: Typography = tagCard.font == .pretendard ? .som.body1WithBold : .som.schoolBody1WithBold
//        if hasScrollEnabled {
//            var attributes = typography.attributes
//            attributes.updateValue(typography.font, forKey: .font)
//            attributes.updateValue(UIColor.som.white, forKey: .foregroundColor)
//            cardTextContentScrollView.attributedText = .init(
//                string: tagCard.content,
//                attributes: attributes
//            )
//            cardTextContentScrollView.textAlignment = .center
//        } else {
//            cardTextContentLabel.typography = typography
//            cardTextContentLabel.text = tagCard.content
//            cardTextContentLabel.textAlignment = .center
//            cardTextContentLabel.lineBreakMode = .byTruncatingTail
//        }
//        // 하단 정보
//        likeImageView.image = tagCard.isLiked ?
//            .init(.icon(.filled(.heart))) :
//            .init(.icon(.outlined(.heart)))
//        likeImageView.tintColor = tagCard.isLiked ? .som.p300 : .som.white
//
//        commentImageView.image = tagCard.isCommentWritten ?
//            .init(.icon(.filled(.comment))) :
//            .init(.icon(.outlined(.comment)))
//        commentImageView.tintColor = tagCard.isCommentWritten ? .som.p300 : .som.white
//        
//        timeLabel.text = tagCard.createdAt.toKorea().infoReadableTimeTakenFromThis(to: Date().toKorea())
//        distanceInfoStackView.isHidden = tagCard.distance == nil
//        distanceLabel.text = (tagCard.distance ?? 0).infoReadableDistanceRangeFromThis()
//        likeLabel.text = "\(tagCard.likeCnt)"
//        likeLabel.textColor = tagCard.isLiked ? .som.p300 : .som.white
//        commentLabel.text = "\(tagCard.commentCnt)"
//        commentLabel.textColor = tagCard.isCommentWritten ? .som.p300 : .som.white
//
//        cardPungTimeBackgroundView.isHidden = true
    }
    
    // TODO: 카드 본문 배경 블러 뷰 높이 계산 함수, 헌재 사용 X
    private func updateContentHeight(_ text: String) {
        
        self.layoutIfNeeded()
        // TODO: 임시, 폰트 가변임
        let typography = Typography.som.v2.body1
        var attributes = typography.attributes
        attributes.updateValue(typography.font, forKey: .font)
        let attributedText = NSAttributedString(
            string: text,
            attributes: attributes
        )
        
        let availableWidth = UIScreen.main.bounds.width - 16 * 2 - 32 * 2 - 24 * 2
        let size: CGSize = .init(width: availableWidth, height: .greatestFiniteMagnitude)
        let boundingRect = attributedText.boundingRect(
            with: size,
            options: [.usesLineFragmentOrigin],
            context: nil
        )
        let boundingHeight = boundingRect.height + 20 * 2 /// top, bottom inset
        let backgroundHeight = rootContainerImageView.bounds.height
        
        let height = min(boundingHeight, (backgroundHeight - 34) * 0.8)
        
        self.contentHeightConstraint?.update(offset: height)
        
        if self.hasScrollEnabled {
            self.cardTextContentScrollView.isScrollEnabled = boundingHeight > backgroundHeight * 0.5
            self.cardTextContentScrollView.isUserInteractionEnabled = true
            self.cardTextContentScrollView.contentSize = .init(
                width: cardTextContentScrollView.bounds.width,
                height: boundingHeight
            )
        }
    }
    
    
    // MARK: - 카드 펑 로직
    
    /// 펑 이벤트 구독
    private func subscribePungTime(_ pungTime: Date?) {
        self.serialTimer?.dispose()
        self.serialTimer = Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)
            .withUnretained(self)
            .startWith((self, 0))
            .map { object, _ in
                guard let pungTime = pungTime else {
                    object.serialTimer?.dispose()
                    return "00 : 00 : 00"
                }
                
                let currentDate = Date()
                let remainingTime = currentDate.infoReadableTimeTakenFromThisForPung(to: pungTime)
                if remainingTime == "00 : 00 : 00" {
                    object.serialTimer?.dispose()
                    object.updatePungUI()
                }
                
                return remainingTime
            }
            .bind(to: self.cardPungTimeLabel.rx.text)
    }
    
    /// 펑 ui 즉각적으로 업데이트
    private func updatePungUI() {
        self.cardPungTimeLabel.text = "00 : 00 : 00"
        self.rootContainerImageView.layer.borderWidth = 0
        self.rootContainerImageView.image = UIColor.som.v2.gray200.toImage
        self.cardInfoContainer.subviews
            .filter { $0 != self.cardInfoLeadingStackView }
            .forEach { $0.removeFromSuperview() }
        self.cardInfoLeadingStackView.subviews
            .filter { $0 != self.cardPungTimeStackView }
            .forEach { $0.removeFromSuperview() }
        
        if self.hasScrollEnabled {
            self.cardTextContentScrollView.text = Text.pungedCardText
        } else {
            self.cardTextContentLabel.text = Text.pungedCardText
        }
    }
}
