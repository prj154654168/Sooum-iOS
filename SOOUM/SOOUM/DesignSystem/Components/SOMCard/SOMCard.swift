//
//  SOMCard.swift
//  SOOUM
//
//  Created by JDeoks on 9/14/24.
//

import UIKit

import RxSwift
import SnapKit
import Then

class SOMCard: UIView {
    
    /// 정보를 표시할 card
    var card: Card = .init()
    
    /// 스토리 펑타임
    var pungTime: Date?
    
    /// 펑 이벤트 처리 위해 추가
    var disposeBag = DisposeBag()
    
    /// 현재 카드가 펑된 카드인지 확인
    var isPunged: Bool {
        guard let pungTime = self.pungTime else {
            return false
        }
        let remainingTime = pungTime.timeIntervalSince(Date())
        return remainingTime <= 0
    }
    
    func setData(card: Card) {
        // 카드 배경 이미지
        rootContainerImageView.setImage(strUrl: card.backgroundImgURL.url)
        
        // 카드 본문
        cardTextContentLabel.text = card.content
        
        // 하단 정보
        likeImageView.image = card.likeCnt != 0 ?
            .init(.icon(.filled(.heart))) :
            .init(.icon(.outlined(.heart)))
        likeImageView.tintColor = card.likeCnt != 0 ? .som.primary : .som.white
        commentImageView.image = card.commentCnt != 0 ?
            .init(.icon(.filled(.comment))) :
            .init(.icon(.outlined(.comment)))
        commentImageView.tintColor = card.commentCnt != 0 ? .som.primary : .som.white
        
        /// 임시 시간 어떻게 표시하는 지 물어봐야 함
        timeLabel.text = card.createdAt.infoReadableTimeTakenFromThis(to: Date())
        /// 임시 distance가 없을 때 어떻게 표시하는 지 물어봐야 함
        distanceLabel.text = (card.distance ?? 0).infoReadableDistanceRangeFromThis()
        likeLabel.text = "\(card.likeCnt)"
        likeLabel.textColor = card.isLiked ? .som.primary : .som.white
        commentLabel.text = "\(card.commentCnt)"
        commentLabel.textColor = card.commentCnt != 0 ? .som.primary : .som.white
        
        // 스토리 정보 설정
        pungContainerView.isHidden = card.isStory
        if card.isStory {
            self.pungTime = card.storyExpirationTime
            self.cardPungTimeLabel.text = getTimeOutStr(
                pungTime: pungTime ?? Date()
            )
            self.updatePungUI()
            self.subscribePungTime()
        }
    }
    
    let rootContainerImageView = UIImageView().then {
        $0.layer.cornerRadius = 40
        $0.layer.masksToBounds = true
    }
    
    /// 카드 펑 라벨, 배경, 컨테이너 뷰
    let pungContainerView = UIView().then {
        $0.backgroundColor = .clear
    }
    
    /// 카드 펑 라벨 배경
    let cardPungTimeBackgroundView = UIView().then {
        $0.backgroundColor = .som.blue300
        $0.layer.cornerRadius = 12
        $0.layer.masksToBounds = true
    }
    
    /// 카드 펑 남은시간 표시 라벨
    let cardPungTimeLabel = UILabel().then {
        $0.typography = .init(
            fontContainer: Pretendard(
                size: 14,
                weight: .bold
            ),
            lineHeight: 16.7,
            letterSpacing: 0
        )
        $0.textColor = .som.white
        $0.textAlignment = .center
    }
    
    /// cardTextContentLabel를 감싸는 불투명 컨테이너 뷰
    let cardTextContainerView = UIView().then {
        $0.backgroundColor = .som.dimForCard
        $0.layer.cornerRadius = 24
    }
    
    /// 본문 표시 라벨
    let cardTextContentLabel = UILabel().then {
        $0.typography = .init(
            fontContainer: Pretendard(
                size: 16,
                weight: .bold
            ),
            lineHeight: 30,
            letterSpacing: 0
        )
        $0.textColor = .som.white
        $0.numberOfLines = 0
        $0.textAlignment = .center
    }
    
    let cardGradientView = UIView().then {
        $0.backgroundColor = .clear
    }
    
    let cardGradientLayer = CAGradientLayer()
    
    /// 좋아요, 거리, 댓글, 시간 정보 포함하는 스택뷰
    let cardContentStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 8
    }
    
    /// 시간 정보 표시 스택뷰
    let timeInfoStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 4
    }
    
    let timeImageView = UIImageView().then {
        $0.image = .init(.icon(.outlined(.clock)))
        $0.tintColor = .som.white
    }
    
    let timeLabel = UILabel().then {
        $0.typography = .init(
            fontContainer: Pretendard(
                size: 10,
                weight: .bold
            ),
            lineHeight: 11,
            letterSpacing: 0
        )
        $0.textColor = .som.white
    }
    
    /// 거리 정보 표시 스택뷰
    let distanceInfoStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 4
    }
    
    let distanceImageView = UIImageView().then {
        $0.image = .init(.icon(.outlined(.location)))
        $0.tintColor = .som.white
    }
    
    let distanceLabel = UILabel().then {
        $0.typography = .init(
            fontContainer: Pretendard(
                size: 10,
                weight: .bold
            ),
            lineHeight: 11,
            letterSpacing: 0
        )
        $0.textColor = .som.white
    }
    
    /// 좋아요 정보 표시 스택뷰
    let likeInfoStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 4
    }
    
    let likeImageView = UIImageView().then {
        $0.image = .init(.icon(.outlined(.heart)))
        $0.tintColor = .som.white
    }
    
    let likeLabel = UILabel().then {
        $0.typography = .init(
            fontContainer: Pretendard(
                size: 10,
                weight: .bold
            ),
            lineHeight: 11,
            letterSpacing: 0
        )
        $0.textColor = .som.white
    }
    
    /// 댓글 정보 표시 스택뷰
    let commentInfoStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 4
    }
    
    let commentImageView = UIImageView().then {
        $0.image = .init(.icon(.outlined(.comment)))
        $0.tintColor = .som.white
    }
    
    let commentLabel = UILabel().then {
        $0.typography = .init(
            fontContainer: Pretendard(
                size: 10,
                weight: .bold
            ),
            lineHeight: 11,
            letterSpacing: 0
        )
        $0.textColor = .som.white
    }
    
    // MARK: - init
    convenience init() {
        self.init(frame: .zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        cardGradientLayer.frame = cardGradientView.bounds
    }
    
    /// 이 컴포넌트를 사용하는 재사용 셀에서 호출
    func prepareForReuse() {
        disposeBag = DisposeBag()
    }
    
    // MARK: - initUI
    private func initUI() {
        addSubviews()
        initConstraint()
        addGradient()
    }
    
    private func addSubviews() {
        self.addSubview(rootContainerImageView)
        addCardPungTimeLabel()
        addCardTextContainerView()
        addCardGradientView()
        addCardContentStackView()
    }
    
    private func addCardPungTimeLabel() {
        rootContainerImageView.addSubview(pungContainerView)
        pungContainerView.addSubview(cardPungTimeBackgroundView)
        cardPungTimeBackgroundView.addSubview(cardPungTimeLabel)
    }
    
    private func addCardTextContainerView() {
        cardTextContainerView.addSubview(cardTextContentLabel)
        rootContainerImageView.addSubview(cardTextContainerView)
    }
    
    private func addCardContentStackView() {
        cardContentStackView.addArrangedSubviews(
            UIView(),
            timeInfoStackView,
            distanceInfoStackView,
            likeInfoStackView,
            commentInfoStackView
        )
        
        addTimeInfoStackView()
        addDistanceInfoStackView()
        addLikeInfoStackView()
        addCommentInfoStackView()
        
        rootContainerImageView.addSubview(cardContentStackView)
    }
    
    private func addCardGradientView() {
        rootContainerImageView.addSubview(cardGradientView)
        rootContainerImageView.bringSubviewToFront(cardGradientView)
    }
    
    private func addTimeInfoStackView() {
        timeInfoStackView.addArrangedSubviews(timeImageView, timeLabel)
    }
    
    private func addDistanceInfoStackView() {
        distanceInfoStackView.addArrangedSubviews(distanceImageView, distanceLabel)
    }
    
    private func addLikeInfoStackView() {
        likeInfoStackView.addArrangedSubviews(likeImageView, likeLabel)
    }
    
    private func addCommentInfoStackView() {
        commentInfoStackView.addArrangedSubviews(commentImageView, commentLabel)
    }
    
    // MARK: - initConstraint
    private func initConstraint() {
        rootContainerImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(20)
            $0.top.equalToSuperview().inset(5)
            $0.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().inset(5)
        }
        
        pungContainerView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(rootContainerImageView.snp.height).multipliedBy(0.25)
        }
        
        cardPungTimeBackgroundView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.height.equalTo(25)
            $0.width.equalTo(90)
        }
        
        cardPungTimeLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(11)
            $0.top.equalToSuperview()
            $0.trailing.equalToSuperview().inset(11)
            $0.bottom.equalToSuperview()
            $0.centerX.equalToSuperview()
        }
        
        cardTextContainerView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.centerX.equalToSuperview()
            $0.width.equalTo(rootContainerImageView.snp.width).multipliedBy(0.75)
            $0.height.greaterThanOrEqualTo(48)
            $0.height.lessThanOrEqualTo(rootContainerImageView.snp.height).multipliedBy(0.5)
        }
        
        cardTextContentLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(14)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.bottom.equalToSuperview().offset(-14)
        }
        
        cardGradientView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.height.equalTo(60)
        }
        
        cardContentStackView.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(-24)
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-26)
            $0.height.height.equalTo(12)
        }
        
        timeImageView.snp.makeConstraints {
            $0.height.width.equalTo(12)
        }
        
        distanceImageView.snp.makeConstraints {
            $0.height.width.equalTo(12)
        }
        
        likeImageView.snp.makeConstraints {
            $0.height.width.equalTo(12)
        }
        
        commentImageView.snp.makeConstraints {
            $0.height.width.equalTo(12)
        }
    }
    
    /// cardGradientLayer
    private func addGradient() {
        cardGradientLayer.colors = [
            UIColor.clear.cgColor,
            UIColor.black.withAlphaComponent(0.24).cgColor
        ]
        cardGradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        cardGradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        cardGradientView.layer.insertSublayer(cardGradientLayer, at: 0)
    }
    
    /// 카드 모드에 따라 스택뷰 순서 변경
    func changeOrderInCardContentStack(_ selectedIndex: Int) {
        self.cardContentStackView.subviews.forEach { $0.removeFromSuperview() }
        
        switch selectedIndex {
        case 1:
            cardContentStackView.addArrangedSubviews(
                UIView(),
                likeInfoStackView,
                commentInfoStackView,
                timeInfoStackView,
                distanceInfoStackView
            )
        case 2:
            cardContentStackView.addArrangedSubviews(
                UIView(),
                distanceInfoStackView,
                timeInfoStackView,
                likeInfoStackView,
                commentInfoStackView
            )
        default:
            cardContentStackView.addArrangedSubviews(
                UIView(),
                timeInfoStackView,
                distanceInfoStackView,
                likeInfoStackView,
                commentInfoStackView
            )
        }
    }
    
    // MARK: - 카드 펑 로직
    
    /// 펑 이벤트 구독
    func subscribePungTime() {
        Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self, let pungTime = self.pungTime else {
                    return
                }
                if isPunged {
                    updatePungUI()
                } else {
                    self.cardPungTimeLabel.text = self.getTimeOutStr(pungTime: pungTime)
                }
            })
            .disposed(by: disposeBag)
    }

    /// 매 초마다 펑 여부 확인 이벤트 구독
    func getTimeOutStr(pungTime: Date) -> String {
        let remainingTime = Int(pungTime.timeIntervalSince(Date()))

        if remainingTime <= 0 {
            return "00:00:00"
        }
        
        let hours = remainingTime / 3600
        let minutes = (remainingTime % 3600) / 60
        let seconds = remainingTime % 60
        
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    /// 펑 ui 즉각적으로 업데이트
    func updatePungUI() {
        if isPunged {
            // TODO: - 펑 디자인 나오면 수정 필요
            self.cardPungTimeLabel.text = "00:00:00"
            self.cardTextContentLabel.text = "펑된 카드입니다."
        }
    }
}
