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
    /// 셀 카드 펑 이벤트
    let didpung = PublishSubject<Void>()
    var isPunged: Bool {
        return self.cardView.isPunged
    }
    
    /// 카드 뷰 컴포넌트
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
        cardView.prepareForReuse()
    }
    
    // MARK: - setData
    /// 셀의 ui에 데이터 바인딩 하는 함수. cellForRowAt에서 호출
    func setData(card: Card) {
        cardView.setData(card: card)
    }
    
    /// 컨텐츠 모드에 따라 정보 스택뷰 순서 변경
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
}
