//
//  TermsOfServiceAgreeButtonView.swift
//  SOOUM
//
//  Created by JDeoks on 11/7/24.
//

import UIKit

import ReactorKit
import RxCocoa
import RxGesture
import RxSwift

import SnapKit
import Then

class TermsOfServiceAgreeButtonView: UIView {
    let checkImageView = UIImageView().then {
        $0.image = .termsOfServiceCheck
        $0.tintColor = .som.gray01
    }
    
    let titleLabel = UILabel().then {
        $0.typography = .init(
            fontContainer: BuiltInFont(
                size: 18,
                weight: .semibold
            ),
            lineHeight: 24.5,
            letterSpacing: 0
        )
        $0.text = "약관 전체 동의"
        $0.textColor = .som.gray01
    }
    
    // MARK: - init
    convenience init() {
        self.init(frame: .zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initConstraint()
        self.layer.borderColor = UIColor.som.gray01.cgColor
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 12
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - initConstraint
    private func initConstraint() {
        self.addSubviews(checkImageView)
        checkImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.top.equalToSuperview().offset(18)
            $0.centerY.equalToSuperview()
        }
        
        self.addSubviews(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.leading.equalTo(checkImageView.snp.trailing).offset(6)
            $0.centerY.equalToSuperview()
        }
    }
    
    func updateState(isOn: Bool) {
        UIView.animate(withDuration: 0.2) {
            self.layer.borderColor = isOn ? UIColor.som.primary.cgColor : UIColor.som.gray01.cgColor
            self.checkImageView.tintColor = isOn ? .som.primary : .som.gray01
        }
        UIView.transition(with: titleLabel, duration: 0.2, options: .transitionCrossDissolve) {
            self.titleLabel.textColor = isOn ? .som.primary : .som.gray01
        }
    }
}
