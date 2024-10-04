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
    
    var model: SOMCardModel?
    
    var isDetail: Bool = false {
        didSet {
            self.updateDetailViewWithHidden(self.isDetail)
        }
    }
    
    var isComment: Bool = false {
        didSet {
            self.updateCommentViewWithHidden(self.isComment)
        }
    }
    
    /// 펑 이벤트 처리 위해 추가
    var disposeBag = DisposeBag()
    
    let rootContainerImageView = UIImageView().then {
        $0.layer.cornerRadius = 40
        $0.layer.masksToBounds = true
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
    
    /// 상세보기, 전글 배경
    let detailPrevCardBackgroundImageView = UIImageView().then {
        $0.layer.borderColor = UIColor.som.white.cgColor
        $0.layer.borderWidth = 2
        $0.layer.cornerRadius = 14
        $0.layer.masksToBounds = true
    }
    /// 상세보기, 전글 라벨
    let detailPrevCardTextLabel = UILabel().then {
        $0.text = "전글"
        $0.textColor = .som.white
        $0.typography = .init(
            fontContainer: Pretendard(size: 14, weight: .medium),
            lineHeight: 15.56,
            letterSpacing: -0.04
        )
    }
    
    /// 상세보기, 상단 오른쪽 설정 버튼
    let detailRightTopSettingButton = UIButton().then {
        var config = UIButton.Configuration.plain()
        config.image = .init(.icon(.outlined(.more)))
        config.image?.withTintColor(.som.gray04)
        config.imageColorTransformer = UIConfigurationColorTransformer { _ in .som.gray04 }
        $0.configuration = config
    }
    
    /// cardTextContentLabel를 감싸는 불투명 컨테이너 뷰
    let cardTextBackgroundView = UIView().then {
        $0.backgroundColor = .clear
        $0.layer.cornerRadius = 24
        $0.clipsToBounds = true
    }
    let cardTextBackgroundBlurView = UIVisualEffectView().then {
        let blurEffect = UIBlurEffect(style: .dark)
        $0.effect = blurEffect
        $0.backgroundColor = .som.dimForCard
        $0.alpha = 0.8
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
        addDetailPrevCardLabel()
        addDetailSettingButton()
        addCardTextContainerView()
        addCardGradientView()
        addCardContentStackView()
    }
    
    private func addCardPungTimeLabel() {
        rootContainerImageView.addSubview(cardPungTimeBackgroundView)
        cardPungTimeBackgroundView.addSubview(cardPungTimeLabel)
    }
    
    private func addDetailPrevCardLabel() {
        rootContainerImageView.addSubview(detailPrevCardBackgroundImageView)
        detailPrevCardBackgroundImageView.addSubview(detailPrevCardTextLabel)
    }
    
    private func addDetailSettingButton() {
        rootContainerImageView.addSubview(detailRightTopSettingButton)
    }
    
    private func addCardTextContainerView() {
        rootContainerImageView.addSubview(cardTextBackgroundView)
        cardTextBackgroundView.addSubview(cardTextBackgroundBlurView)
        cardTextBackgroundView.addSubview(cardTextContentLabel)
    }
    
    private func addCardContentStackView() {
        rootContainerImageView.addSubview(cardContentStackView)
        
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
        /// 홈피드 이미지 배경
        rootContainerImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        /// 펑 라벨
        cardPungTimeBackgroundView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(26)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(25)
        }
        cardPungTimeLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(10)
        }
        
        /// 상세보기, 전글 라벨
        detailPrevCardBackgroundImageView.snp.makeConstraints {
            $0.top.leading.equalToSuperview().offset(16)
            $0.size.equalTo(44)
        }
        detailPrevCardTextLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(10)
        }
        
        /// 상세보기, 상단 오른쪽 설정 버튼
        detailRightTopSettingButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(26)
            $0.trailing.equalToSuperview().offset(-26)
            $0.size.equalTo(24)
        }
        
        /// 본문 라벨
        cardTextBackgroundView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
        }
        cardTextBackgroundBlurView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        cardTextContentLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(14)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.bottom.equalToSuperview().offset(-14)
        }
        
        /// 하단 그라디언트 뷰
        cardGradientView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.height.equalTo(60)
        }
        
        /// 하단 컨텐트 뷰
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
            UIColor.black.withAlphaComponent(0.6).cgColor
        ]
        cardGradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        cardGradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        cardGradientView.layer.insertSublayer(cardGradientLayer, at: 0)
    }
    
    private func updateDetailViewWithHidden(_ isDetail: Bool) {
        detailPrevCardBackgroundImageView.isHidden = !isDetail
        detailRightTopSettingButton.isHidden = !isDetail
        likeInfoStackView.isHidden = isDetail
        commentInfoStackView.isHidden = isDetail
    }
    
    private func updateCommentViewWithHidden(_ isComment: Bool) {
        cardPungTimeBackgroundView.isHidden = isComment
    }
    
    /// 홈피드 모델 초기화
    func setModel(model: SOMCardModel) {
        
        self.model = model
        self.isDetail = model.isDetail
        self.isComment = model.isComment
        // 카드 배경 이미지
        rootContainerImageView.setImage(strUrl: model.data.backgroundImgURL.url)
        
        // 카드 본문
        cardTextContentLabel.text = model.data.content
        
        // 하단 정보
        likeImageView.image = model.data.likeCnt != 0 ?
            .init(.icon(.filled(.heart))) :
            .init(.icon(.outlined(.heart)))
        likeImageView.tintColor = model.data.likeCnt != 0 ? .som.primary : .som.white
        commentImageView.image = model.data.commentCnt != 0 ?
            .init(.icon(.filled(.comment))) :
            .init(.icon(.outlined(.comment)))
        commentImageView.tintColor = model.data.commentCnt != 0 ? .som.primary : .som.white
        
        /// 임시 시간 어떻게 표시하는 지 물어봐야 함
        timeLabel.text = model.data.createdAt.infoReadableTimeTakenFromThis(to: Date())
        /// 임시 distance가 없을 때 어떻게 표시하는 지 물어봐야 함
        distanceLabel.text = (model.data.distance ?? 0).infoReadableDistanceRangeFromThis()
        likeLabel.text = "\(model.data.likeCnt)"
        likeLabel.textColor = model.data.isLiked ? .som.primary : .som.white
        commentLabel.text = "\(model.data.commentCnt)"
        commentLabel.textColor = model.data.commentCnt != 0 ? .som.primary : .som.white
        
        // 스토리 정보 설정
        cardPungTimeBackgroundView.isHidden = !model.data.isStory
        if model.data.isStory {
            self.model?.pungTime = model.data.storyExpirationTime
            self.cardPungTimeLabel.text = getTimeOutStr(
                pungTime: self.model?.pungTime ?? Date()
            )
            self.updatePungUI()
            self.subscribePungTime()
        }
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
                guard let self = self, let pungTime = self.model?.pungTime else {
                    return
                }
                if self.model?.isPunged == true {
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
        if self.model?.isPunged == true {
            // TODO: - 펑 디자인 나오면 수정 필요
            self.cardPungTimeLabel.text = "00:00:00"
            self.cardTextContentLabel.text = "펑된 카드입니다."
        }
    }
}
