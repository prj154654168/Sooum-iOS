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
    
    enum CardType {
        case feed
        case comment
    }
    
    
    // MARK: Views
    
    private let shadowbackgroundView = UIView().then {
        $0.backgroundColor = .som.v2.white
        $0.layer.cornerRadius = 16
    }
    
    /// 배경 이미지
    private let rootContainerImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.layer.cornerRadius = 16
        $0.layer.borderWidth = 1
        $0.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        $0.layer.masksToBounds = true
    }
    
    // 본문 dim 배경
    private let cardTextBackgroundBlurView = UIView().then {
        $0.backgroundColor = .som.v2.dim
        $0.layer.cornerRadius = 12
        $0.clipsToBounds = true
    }
    
    /// 본문 표시 라벨 (스크롤 X)
    private let cardTextContentLabel = UILabel().then {
        $0.textColor = .som.v2.white
        $0.typography = .som.v2.body1
        $0.textAlignment = .center
        $0.numberOfLines = 4
        $0.lineBreakMode = .byTruncatingTail
        $0.lineBreakStrategy = .hangulWordPriority
    }
    
    /// 펑 시간, 거리, 시간, 좋아요 수, 답글 수 정보를 담는 뷰
    private let cardInfoContainer = UIView().then {
        $0.backgroundColor = .som.v2.white
        $0.layer.cornerRadius = 16
        $0.layer.borderWidth = 1
        $0.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        $0.layer.masksToBounds = true
    }
    /// 펑 시간, 거리, 시간을 담는 스택 뷰
    private let cardInfoLeadingStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 4
        $0.alignment = .center
    }
    /// 좋아요 수, 답글 수를 담는 스택 뷰
    private let cardInfoTrailingStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 4
        $0.alignment = .center
    }
    
    /// 어드민 정보 표시 스택뷰
    private let adminStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 2
        $0.alignment = .center
    }
    /// 어드민 정보 아이콘
    private let adminImageView = UIImageView().then {
        $0.image = .init(.icon(.v2(.filled(.official))))
        $0.tintColor = .som.v2.black
    }
    /// 어드민 정보 라벨
    private let adminLabel = UILabel().then {
        $0.text = Text.adminTitle
        $0.textColor = .som.v2.black
        $0.typography = .som.v2.caption2
    }
    /// 어드민 닷
    private let firstDot = UIView().then {
        $0.backgroundColor = .som.v2.gray500
        $0.layer.cornerRadius = 1
    }
    /// 펑 남은시간 표시 스택뷰
    private let cardPungTimeStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 2
        $0.alignment = .center
    }
    /// 펑 남은시간 표시 아이콘
    private let cardPungTimeImageView = UIImageView().then {
        $0.image = .init(.icon(.v2(.outlined(.timer))))
        $0.tintColor = .som.v2.pMain
    }
    /// 펑 남은시간 표시 라벨
    private let cardPungTimeLabel = UILabel().then {
        $0.textColor = .som.v2.pDark
        $0.typography = .som.v2.caption2
    }
    /// 펑 남은시간 닷
    private let secondDot = UIView().then {
        $0.backgroundColor = .som.v2.gray500
        $0.layer.cornerRadius = 1
    }
    /// 거리 정보 표시 스택뷰
    private let distanceInfoStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 2
        $0.alignment = .center
    }
    /// 거리 정보 아이콘
    private let distanceImageView = UIImageView().then {
        $0.image = .init(.icon(.v2(.outlined(.location))))
        $0.tintColor = .som.v2.gray500
    }
    /// 거리 정보 라벨
    private let distanceLabel = UILabel().then {
        $0.textColor = .som.v2.gray500
        $0.typography = .som.v2.caption2
    }
    /// 거리 정보 닷
    private let thirdDot = UIView().then {
        $0.backgroundColor = .som.v2.gray500
        $0.layer.cornerRadius = 1
    }
    /// 시간 정보 표시 라벨
    private let timeLabel = UILabel().then {
        $0.textColor = .som.v2.gray500
        $0.typography = .som.v2.caption2
    }
    /// 좋아요 정보 표시 스택뷰
    private let likeInfoStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 2
        $0.alignment = .center
    }
    /// 좋아요 정보 표시 아이콘
    private let likeImageView = UIImageView().then {
        $0.image = .init(.icon(.v2(.outlined(.heart))))
        $0.tintColor = .som.v2.gray500
    }
    /// 좋아요 정보 표시 라벨
    private let likeLabel = UILabel().then {
        $0.textColor = .som.v2.gray500
        $0.typography = .som.v2.caption2
    }
    /// 답카드 정보 표시 스택뷰
    private let commentInfoStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 2
        $0.alignment = .center
    }
    /// 답카드 정보 표시 아이콘
    private let commentImageView = UIImageView().then {
        $0.image = .init(.icon(.v2(.outlined(.message_circle))))
        $0.tintColor = .som.v2.gray500
    }
    /// 답카드 정보 표시 라벨
    private let commentLabel = UILabel().then {
        $0.textColor = .som.v2.gray500
        $0.typography = .som.v2.caption2
    }
    
    
    // MARK: Variables
    
    private(set) var model: BaseCardInfo = .defaultValue
    private(set) var cardType: CardType
    
    
    // MARK: Constraints
    
    // TODO: 카드 본문 높이 계산 Constraint
    private var contentHeightConstraint: Constraint?
    
    /// 펑 이벤트 처리 위해 추가
    var serialTimer: Disposable?
    var disposeBag = DisposeBag()
    
    
    // MARK: Initialize
    
    init(type cardType: CardType = .feed) {
        self.cardType = cardType
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
            $0.top.horizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-34)
        }
        
        // 하단 카드 정보 컨테이너
        self.addSubview(self.cardInfoContainer)
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
        
        self.cardInfoLeadingStackView.addArrangedSubview(self.distanceInfoStackView)
        self.cardInfoLeadingStackView.addArrangedSubview(self.thirdDot)
        self.thirdDot.snp.makeConstraints {
            $0.size.equalTo(2)
        }
        
        self.cardInfoLeadingStackView.addArrangedSubview(self.timeLabel)
        self.cardInfoLeadingStackView.addArrangedSubview(self.secondDot)
        self.secondDot.snp.makeConstraints {
            $0.size.equalTo(2)
        }
        
        self.cardInfoLeadingStackView.addArrangedSubview(self.cardPungTimeStackView)
        
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
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(32)
            $0.trailing.equalToSuperview().offset(-32)
        }
        
        self.cardTextBackgroundBlurView.addSubview(self.cardTextContentLabel)
        self.cardTextContentLabel.snp.makeConstraints {
            let verticalOffset: CGFloat = self.cardType == .feed ? 20 : 16
            $0.top.equalToSuperview().offset(verticalOffset)
            $0.bottom.equalToSuperview().offset(-verticalOffset)
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalToSuperview().offset(-24)
            self.contentHeightConstraint = $0.height.equalTo(Typography.som.v2.body1.lineHeight).constraint
        }
    }
    
    
    // MARK: Public func
    
    /// 이 컴포넌트를 사용하는 재사용 셀에서 호출
    func prepareForReuse() {
        self.serialTimer?.dispose()
        self.disposeBag = DisposeBag()
        
        self.adminLabel.text = nil
        self.cardPungTimeLabel.text = nil
        self.distanceLabel.text = nil
        self.timeLabel.text = nil
        self.likeLabel.text = nil
        self.commentLabel.text = nil
    }
    
    /// 홈피드 모델 초기화
    func setModel(model: BaseCardInfo) {
        
        self.model = model
        
        let borderColor = model.isAdminCard ? UIColor.som.v2.pMain : UIColor.som.v2.gray100
        // 카드 배경 이미지
        self.rootContainerImageView.setImage(strUrl: model.cardImgURL, with: model.cardImgName)
        self.rootContainerImageView.layer.borderColor = borderColor.cgColor
        
        // 카드 본문
        let typography: Typography
        switch model.font {
        case .pretendard:   typography = .som.v2.body1
        case .ridi:         typography = .som.v2.ridiCard
        case .yoonwoo:      typography = .som.v2.yoonwooCard
        case .kkookkkook:   typography = .som.v2.kkookkkookCard
        }
        self.cardTextContentLabel.text = model.cardContent
        self.cardTextContentLabel.typography = typography
        self.updateContentHeight(model.cardContent, with: typography)
        
        // 하단 정보
        // 어드민, 펑 시간, 거리, 시간
        self.cardInfoContainer.layer.borderColor = borderColor.cgColor
        
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
        self.likeLabel.text = likeText
        self.likeLabel.typography = .som.v2.caption2
        
        let commentText = model.commentCnt > 99 ? "99+" : "\(model.commentCnt)"
        self.commentLabel.text = commentText
        self.commentLabel.typography = .som.v2.caption2
        
        // 스토리 정보 설정
        self.subscribePungTime(model.storyExpirationTime)
    }
    
    private func updateContentHeight(_ text: String, with typography: Typography) {
        
        UIView.performWithoutAnimation {
            self.layoutIfNeeded()
        }

        var attributes = typography.attributes
        attributes.updateValue(typography.font, forKey: .font)
        let attributedText = NSAttributedString(
            string: text,
            attributes: attributes
        )
        /// screen width - SOMCard horizontal padding - text background dim view horizontal padding - text horizontal inset
        let availableWidth = self.cardTextContentLabel.bounds.width
        let size: CGSize = .init(width: availableWidth, height: .greatestFiniteMagnitude)
        let boundingHeight = attributedText.boundingRect(
            with: size,
            options: [.usesLineFragmentOrigin],
            context: nil
        ).height
        
        let maxHeight = self.cardType == .feed ? typography.lineHeight * 3 : typography.lineHeight * 4
        let height = min(boundingHeight, maxHeight)
        
        self.contentHeightConstraint?.update(offset: height)
        
        UIView.performWithoutAnimation {
            self.layoutIfNeeded()
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
                    return "00:00:00"
                }
                
                let currentDate = Date()
                let remainingTime = currentDate.infoReadableTimeTakenFromThisForPung(to: pungTime)
                if remainingTime == "00:00:00" {
                    object.serialTimer?.dispose()
                    object.updatePungUI()
                }
                
                return remainingTime
            }
            .bind(to: self.cardPungTimeLabel.rx.text)
    }
    
    /// 펑 ui 즉각적으로 업데이트
    private func updatePungUI() {
        self.cardPungTimeLabel.text = "00:00:00"
        self.rootContainerImageView.layer.borderWidth = 0
        self.rootContainerImageView.image = UIColor.som.v2.gray200.toImage
        self.cardInfoContainer.layer.borderWidth = 0
        self.cardInfoContainer.subviews
            .filter { $0 != self.cardInfoLeadingStackView }
            .forEach { $0.removeFromSuperview() }
        self.cardInfoLeadingStackView.subviews
            .filter { $0 != self.cardPungTimeStackView }
            .forEach { $0.removeFromSuperview() }
        
        self.cardTextContentLabel.text = Text.pungedCardText
        self.updateContentHeight(Text.pungedCardText, with: .som.v2.body1)
    }
}
