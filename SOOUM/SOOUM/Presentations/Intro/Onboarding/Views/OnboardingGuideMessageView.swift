//
//  OnboardingGuideMessageView.swift
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
class OnboardingGuideMessageView: UIView {
    
    
    // MARK: Views
    
    private let numberingView = OnboardingNumberingView(numbers: [1, 2, 3])
    
    private let titleLabel = UILabel().then {
        $0.textColor = .som.v2.black
        $0.typography = .som.v2.head2.withAlignment(.left)
        $0.lineBreakMode = .byWordWrapping
        $0.lineBreakStrategy = .hangulWordPriority
        $0.numberOfLines = 0
    }
    
    
    // MARK: Variables
    
    var title: String? {
        set {
            let attributes = Typography.som.v2.head2.withAlignment(.left).attributes
            self.titleLabel.attributedText = .init(string: newValue ?? "", attributes: attributes)
        }
        get {
            return self.titleLabel.text
        }
    }
    
    var currentNumber: Int {
        set {
            self.numberingView.currentNumber = newValue
        }
        get {
            self.numberingView.currentNumber ?? 0
        }
    }
    
    
    // MARK: Initalization
    
    convenience init(title: String, currentNumber: Int) {
        self.init(frame: .zero)
        
        self.title = title
        self.currentNumber = currentNumber
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: Private Func
    
    private func setupConstraints() {
        
        self.addSubview(self.numberingView)
        self.numberingView.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
            $0.trailing.lessThanOrEqualToSuperview()
        }
        
        self.addSubview(self.titleLabel)
        self.titleLabel.snp.makeConstraints {
            $0.top.equalTo(self.numberingView.snp.bottom).offset(16)
            $0.bottom.leading.equalToSuperview()
            $0.trailing.lessThanOrEqualToSuperview()
        }
    }
}
