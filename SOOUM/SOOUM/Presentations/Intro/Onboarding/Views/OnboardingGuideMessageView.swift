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
    
    private let titleLabel = UILabel().then {
        $0.textColor = .som.black
        $0.typography = .som.head1WithRegular.withAlignment(.left)
        $0.lineBreakMode = .byWordWrapping
        $0.lineBreakStrategy = .hangulWordPriority
        $0.numberOfLines = 0
    }
    
    private let messageLabel = UILabel().then {
        $0.textColor = .som.gray500
        $0.typography = .som.body2WithRegular
    }
    
    
    // MARK: Variables
    
    var title: String? {
        set {
            self.titleLabel.text = newValue
        }
        get {
            return self.titleLabel.text
        }
    }
    
    var message: String? {
        set {
            self.messageLabel.text = newValue
            self.messageLabel.isHidden = newValue == nil
        }
        get {
            return self.messageLabel.text
        }
    }
    
    
    // MARK: Initalization
    
    convenience init(title: String, message: String? = nil) {
        self.init(frame: .zero)
        
        self.title = title
        self.message = message
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
        
        self.addSubview(self.titleLabel)
        self.titleLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
            $0.trailing.lessThanOrEqualToSuperview()
        }
        
        self.addSubview(self.messageLabel)
        self.messageLabel.snp.makeConstraints {
            $0.top.equalTo(self.titleLabel.snp.bottom).offset(16)
            $0.bottom.leading.equalToSuperview()
            $0.trailing.lessThanOrEqualToSuperview()
        }
    }
}
