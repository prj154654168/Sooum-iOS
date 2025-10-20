//
//  SelectTypographyView.swift
//  SOOUM
//
//  Created by 오현식 on 10/11/25.
//

import UIKit

import SnapKit
import Then

import RxCocoa
import RxGesture
import RxSwift

class SelectTypographyView: UIView {
    
    typealias TypographyWithName = (name: String, typography: Typography)
    
    enum Text {
        static let title: String = "글씨체"
    }
    
    
    // MARK: Views
    
    private let titleLabel = UILabel().then {
        $0.text = Text.title
        $0.textColor = .som.v2.pDark
        $0.typography = .som.v2.caption1
    }
    
    private let container = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .fill
        $0.distribution = .equalSpacing
        $0.spacing = 8
    }
    
    
    // MARK: Variables
    
    var selectedTypography = BehaviorRelay<BaseCardInfo.Font?>(value: nil)
    var selectTypography: BaseCardInfo.Font = .pretendard {
        didSet {
            
            let items = self.container.arrangedSubviews
                .compactMap { $0 as? UIStackView }
                .flatMap { $0.arrangedSubviews }
                .compactMap { $0 as? SelectTypographyItem }
            
            items.enumerated().forEach { index, item in
                var font: BaseCardInfo.Font? {
                    switch index {
                    case 0: return .pretendard
                    case 1: return .ridi
                    case 2: return .yoonwoo
                    case 3: return .kkookkkook
                    default: return nil
                    }
                }
                item.isSelected = font == self.selectTypography
            }
            
            self.selectedTypography.accept(self.selectTypography)
        }
    }
    
    var items: [TypographyWithName] = [] {
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
    
    private func setupItems(_ items: [TypographyWithName]) {
        
        let firstContainer = UIStackView().then {
            $0.axis = .horizontal
            $0.alignment = .fill
            $0.distribution = .equalSpacing
            $0.spacing = 8
        }
        
        let secondContainer = UIStackView().then {
            $0.axis = .horizontal
            $0.alignment = .fill
            $0.distribution = .equalSpacing
            $0.spacing = 8
        }
        
        items.enumerated().forEach { index, value in
            
            let item = SelectTypographyItem(title: value.name, typography: value.typography)
            item.isSelected = index == 0
            item.rx.tapGesture()
                .when(.recognized)
                .subscribe(with: self) { object, _ in
                    var font: BaseCardInfo.Font? {
                        switch index {
                        case 0: return .pretendard
                        case 1: return .ridi
                        case 2: return .yoonwoo
                        case 3: return .kkookkkook
                        default: return nil
                        }
                    }
                    guard let font = font else { return }
                    
                    object.selectTypography = font
                }
                .disposed(by: self.disposeBag)
            
            item.snp.makeConstraints {
                let width: CGFloat = (UIScreen.main.bounds.width - 16 * 2 - 8) * 0.5
                $0.width.equalTo(width)
                $0.height.equalTo(48)
            }
            
            if index < 2 {
                firstContainer.addArrangedSubview(item)
            } else {
                secondContainer.addArrangedSubview(item)
            }
        }
        self.container.addArrangedSubview(firstContainer)
        self.container.addArrangedSubview(secondContainer)
        /// 초기값
        self.selectTypography = .pretendard
    }
}
