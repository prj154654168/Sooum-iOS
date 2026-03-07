//
//  SelectCardTypeView.swift
//  SOOUM
//
//  Created by 오현식 on 2/1/26.
//

import UIKit

import SnapKit
import Then

import RxCocoa
import RxGesture
import RxSwift

final class SelectCardTypeView: UIView {
    
    enum Text {
        static let title: String = "타입"
    }
    
    
    // MARK: Views
    
    private let titleLabel = UILabel().then {
        $0.text = Text.title
        $0.textColor = .som.v2.pDark
        $0.typography = .som.v2.caption1
    }
    
    private let container = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .fill
        $0.distribution = .equalSpacing
        $0.spacing = 8
    }
    
    
    // MARK: Variables
    
    var selectedCardType = BehaviorRelay<BaseCardInfo.CardType?>(value: nil)
    var selectCardType: BaseCardInfo.CardType = .article {
        didSet {
            
            let items = self.container.arrangedSubviews
                .compactMap { $0 as? SOMButton }
            
            items.enumerated().forEach { index, item in
                var cardType: BaseCardInfo.CardType? {
                    switch index {
                    case 0: return .article
                    case 1: return .default
                    default: return nil
                    }
                }
                item.isSelected = cardType == self.selectCardType
            }
            
            self.selectedCardType.accept(self.selectCardType)
        }
    }
    
    var items: [String] = [] {
        didSet {
            if self.items.isEmpty == false {
                self.setupItems(self.items)
            }
        }
    }
    
    private var disposeBag = DisposeBag()
    
    
    // MARK: Initialize
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        self.setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: Private func
    
    private func setupConstraints() {
        
        self.addSubview(self.titleLabel)
        self.titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().offset(20)
        }
        
        self.addSubview(self.container)
        self.container.snp.makeConstraints {
            $0.top.equalTo(self.titleLabel.snp.bottom).offset(10)
            $0.bottom.equalToSuperview()
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
        }
    }
    
    private func setupItems(_ items: [String]) {
        
        self.container.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        items.enumerated().forEach { index, title in
            
            let item = SOMButton().then {
                $0.title = title
                $0.typography = .som.v2.subtitle1
                $0.foregroundColor = .som.v2.gray600
                $0.backgroundColor = .som.v2.gray100
            }
            item.isSelected = index == 0
            item.rx.throttleTap
                .subscribe(with: self) { object, _ in
                    var cardType: BaseCardInfo.CardType? {
                        switch index {
                        case 0: return .article
                        case 1: return .default
                        default: return nil
                        }
                    }
                    guard let cardType = cardType else { return }
                    
                    object.selectCardType = cardType
                }
                .disposed(by: self.disposeBag)
            
            item.snp.makeConstraints {
                let width: CGFloat = (UIScreen.main.bounds.width - 16 * 2 - 8) * 0.5
                $0.width.equalTo(width)
                $0.height.equalTo(48)
            }
            
            self.container.addArrangedSubview(item)
        }
        /// 초기값
        self.selectCardType = .article
    }
}
