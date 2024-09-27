//
//  SOMCardTableViewCell.swift
//  SOOUM
//
//  Created by JDeoks on 9/12/24.
//

import UIKit

import RxSwift
import SnapKit
import Then


class SOMCardTableViewCell: UITableViewCell {
    
    /// homeSelect 값에 따라 스택뷰 순서 변함
    enum Mode {
        case latest
        case interest
        case distance
    }
    
    var card: Card = .init()
    /// 카드 펑 타임
    var pungTime: Date?
    var isCardPung: Bool = false
    
    /// 셀 카드 펑 이벤트
    let didpung = PublishSubject<Void>()
    
    var disposeBag = DisposeBag()

    let cardView = SOMCard()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    // MARK: - setData
    /// 셀의 ui에 데이터 바인딩 하는 함수. cellForRowAt에서 호출
    func setData(card: Card) {
        
        /// 카드 모델
        self.card = card
        /// 카드 배경 이미지
        self.cardView.rootContainerImageView.setImage(strUrl: card.backgroundImgURL.url)
        /// 카드 본문
        self.cardView.cardTextContentLabel.text = card.content
        /// 하단 정보
        self.cardView.likeImageView.image = card.likeCnt != 0 ?
            .init(.icon(.filled(.heart))) :
            .init(.icon(.outlined(.heart)))
        self.cardView.likeImageView.tintColor = card.likeCnt != 0 ? .som.primary : .som.white
        self.cardView.commentImageView.image = card.commentCnt != 0 ?
            .init(.icon(.filled(.comment))) :
            .init(.icon(.outlined(.comment)))
        self.cardView.commentImageView.tintColor = card.commentCnt != 0 ? .som.primary : .som.white
        /// 임시 시간 어떻게 표시하는 지 물어봐야 함
        self.cardView.timeLabel.text = card.createdAt.infoReadableTimeTakenFromThis(to: Date())
        /// 임시 distance가 없을 때 어떻게 표시하는 지 물어봐야 함
        self.cardView.distanceLabel.text = (card.distance ?? 0).infoReadableDistanceRangeFromThis()
        self.cardView.likeLabel.text = "\(card.likeCnt)"
        self.cardView.likeLabel.textColor = card.isLiked ? .som.primary : .som.white
        self.cardView.commentLabel.text = "\(card.commentCnt)"
        self.cardView.commentLabel.textColor = card.commentCnt != 0 ? .som.primary : .som.white
        
        self.cardView.pungContainerView.isHidden = !card.isStory
        if card.isStory {
            self.pungTime = card.storyExpirationTime
            self.cardView.cardPungTimeLabel.text = getTimeOutStr(
                pungTime: card.storyExpirationTime ?? Date()
            )
            
            self.checkCardDidPung()
            self.subscribePungTime()
        }
    }
    
    func changeOrderInCardContentStack(_ selectedIndex: Int) {
        self.cardView.changeOrderInCardContentStack(selectedIndex)
    }
    
    /// 남은 시간 스트링으로 반환
    private func getTimeOutStr(pungTime: Date) -> String {
        let remainingTime = Int(pungTime.timeIntervalSince(Date()))

        if remainingTime <= 0 {
            return "00:00:00"
        }
        
        let hours = remainingTime / 3600
        let minutes = (remainingTime % 3600) / 60
        let seconds = remainingTime % 60
        
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }

    // MARK: - initUI
    private func initUI() {
        self.selectionStyle = .none
        addSubviews()
        initConstraint()
    }
    
    // MARK: - addSubviews
    private func addSubviews() {
        contentView.addSubview(cardView)
    }

    // MARK: - initConstraint
    private func initConstraint() {
        cardView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.top.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
    
    private func subscribePungTime() {
        // 매 1초마다 펑 여부 확인
        Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self, let pungTime = self.pungTime else {
                    return
                }
                let remainingTime = pungTime.timeIntervalSince(Date())
                if remainingTime <= 0 {
                    self.isCardPung = true
                    self.cardView.cardPungTimeLabel.text = "00:00:00"
                    self.cardView.cardTextContentLabel.text = "펑된 카드입니다."
                } else {
                    self.cardView.cardPungTimeLabel.text = getTimeOutStr(pungTime: pungTime)
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func checkCardDidPung() {
        guard let pungTime = self.pungTime else { return }
        
        let remainingTime = pungTime.timeIntervalSince(Date())
        if remainingTime <= 0 {
            // TODO: - 펑 디자인 나오면 수정 필요
            self.cardView.cardPungTimeLabel.text = "00:00:00"
            self.cardView.cardTextContentLabel.text = "펑된 카드입니다."
        }
    }
}
