//
//  OnboardingGuidLabelView.swift
//  SOOUM
//
//  Created by JDeoks on 11/6/24.
//

import UIKit

import ReactorKit
import RxCocoa
import RxGesture
import RxSwift

import SnapKit
import Then

/// 상단 설명 라벨 스택뷰
class OnboardingGuideLabelView: UIView {
    
    let labelStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 16
    }
    
    let titleLabel = UILabel().then {
        $0.typography = .init(
            fontContainer: BuiltInFont(
                size: 22,
                weight: .medium
            ),
            lineHeight: 28,
            letterSpacing: 0
        )
        $0.textColor = .som.black
        $0.numberOfLines = 0
    }
    
    let descLabel = UILabel().then {
        $0.typography = .init(
            fontContainer: BuiltInFont(
                size: 14,
                weight: .regular
            ),
            lineHeight: 19.6,
            letterSpacing: 0
        )
        $0.textColor = .som.gray01
    }
    
    // MARK: - init
    convenience init() {
        self.init(frame: .zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initConstraint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - initConstraint
    private func initConstraint() {
        self.addSubviews(labelStackView)
        labelStackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        labelStackView.addArrangedSubviews(titleLabel, descLabel)
    }
}
